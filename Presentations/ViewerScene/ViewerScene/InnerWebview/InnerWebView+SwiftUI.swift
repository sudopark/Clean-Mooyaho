//
//  InnerWebView+SwiftUI.swift
//  ViewerScene
//
//  Created by sudo.park on 2022/11/10.
//

import SwiftUI
import UIKit
import Combine

import RxSwift
import RxCocoa

import Domain
import CommonPresenting
import WebView


final class InnerWebViewState: ObservableObject {
    
    @Published var isBackwardable: Bool = false
    @Published var isForwardable: Bool = false
    @Published var isEditable = false
    @Published var isJumpable = false
    @Published var startLoadWebPage: WebPageLoadParams?
    @Published var urlPageTitle: String = ""
    @Published var isMarkAsRead: Bool = false
    @Published var hasMemo: Bool = false
    
    @Published var progress: CGFloat = 0.0
    func updatProgress(_ progress: CGFloat) {
        self.progress = progress >= 1.0 ? 0.0 : progress
    }
    
    private let disposeBag = DisposeBag()
    private var didBind = false
    
    func bind(_ viewModel: InnerWebViewViewModel) {
        guard self.didBind == false else { return }
        self.didBind = true
        
        isEditable = viewModel.isEditable
        isJumpable = viewModel.isJumpable
        
        viewModel.startLoadWebPage
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] params in
                self?.startLoadWebPage = params
            })
            .disposed(by: self.disposeBag)
        
        viewModel.urlPageTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.urlPageTitle = title
            })
            .disposed(by: self.disposeBag)
        
        viewModel.isRed
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isMarkAsRead in
                self?.isMarkAsRead = isMarkAsRead
            })
            .disposed(by: self.disposeBag)
        
        viewModel.hasMemo
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] hasMemo in
                self?.hasMemo = hasMemo
            })
            .disposed(by: self.disposeBag)
    }
}


public struct InnerWebView_SwiftUI: View {
    
    private let viewModel: InnerWebViewViewModel
    @StateObject private var state: InnerWebViewState = .init()
    @StateObject private var webviewStore: WebViewStore = .init()
    
    public init(viewModel: InnerWebViewViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            Views.PullGuideView()
                .cornerRadius(10, corners: [.topLeft, .topRight])
                
            ZStack {
                
                WebView(webView: webviewStore.webView)
                    .onReceive(state.$startLoadWebPage) { params in
                        guard let params = params,
                              let url = URL(string: params.urlPath)
                        else { return }
                        self.webviewStore.webView.load(URLRequest(url: url))
                    }
                    .onReceive(webviewStore.webView.publisher(for: \.estimatedProgress)) { progress in
                        self.state.updatProgress(progress)
                    }
                    .onReceive(webviewStore.webView.publisher(for: \.estimatedProgress)
                        .map { $0 >= 1 || self.webviewStore.webView.isLoading == false}
                        .filter { $0 }.first()) { _ in
                        // TODO: handle is first load
                            
                    }
                    .onReceive(webviewStore.webView.publisher(for: \.url)) { url in
                        if let urlPath = url?.absoluteString { self.viewModel.pageLoaded(for: urlPath) }
                        self.updateWebViewNavigationButtons()
                    }
                
                VStack {
                    Spacer()
                    
                    VStack {
                        Divider()
                        
                        InnerWebViewToolbarInfoSection(
                            title: $state.urlPageTitle,
                            isEditable: $state.isEditable,
                            progress: $state.progress
                        )
                        .eventHandler(\.editHandlerWithCopyURL, viewModel.managePageDetail(withCopyURL:))
                        .eventHandler(\.refreshHandler) {
                            guard self.webviewStore.webView.isLoading == false else { return }
                            self.webviewStore.webView.reload()
                        }
                        .padding(.top, 4)
                        .padding(.horizontal, 16)
                        
                        InnerWebViewToolbarControlSection(
                            isEditable: $state.isEditable,
                            isJumpable: $state.isJumpable,
                            isRewindable: $state.isBackwardable,
                            isForwardable: $state.isForwardable,
                            isMarkAsRead: $state.isMarkAsRead,
                            hasNote: $state.hasMemo
                        )
                        .eventHandler(\.backwardHandler) {
                            guard self.webviewStore.webView.canGoBack == true else { return }
                            self.webviewStore.webView.goBack()
                        }
                        .eventHandler(\.forwardHandler) {
                            guard self.webviewStore.canGoForward == true else { return }
                            self.webviewStore.webView.goForward()
                        }
                        .eventHandler(\.markAsReadHandler, viewModel.toggleMarkAsRed)
                        .eventHandler(\.noteHandler, viewModel.editMemo)
                        .eventHandler(\.jumpHandler, viewModel.jumpToCollection)
                        .eventHandler(\.safariHandler, viewModel.openPageInSafari)
                    }
                    .background(VisualEffectView().ignoresSafeArea(edges: [.bottom]))
                }
            }
            .padding(.top, 4)
        }
        .background(theme.colors.appBackground.asColor)
        .onAppear {
            self.state.bind(viewModel)
            viewModel.prepareLinkData()
        }
    }
    
    private func updateWebViewNavigationButtons() {
        let forwardCount = self.webviewStore.webView.backForwardList.forwardList.count
        let backwardCount = self.webviewStore.webView.backForwardList.backList.count
        self.state.isBackwardable = backwardCount > 0
        self.state.isForwardable = forwardCount > 0
    }
}


private struct InnerWebViewToolbarInfoSection: View {
    
    @Binding var title: String
    @Binding var isEditable: Bool
    @Binding var progress: CGFloat
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var editHandlerWithCopyURL: (Bool) -> Void = { _ in }
    var refreshHandler: () -> Void = { }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                
                if self.isEditable {
                    self.editButton
                }
                
                Spacer()
                Text(self.title)
                    .lineLimit(1)
                    .foregroundColor(self.theme.colors.text.withAlphaComponent(0.8).asColor)
                    .font(self.theme.fonts.get(12, weight: .regular).asFont)
                    .onTapGesture {
                        self.editHandlerWithCopyURL(true)
                    }
                Spacer()
                
                self.refreshButton
            }
            .padding([.horizontal], 16)
            .padding([.vertical], 7)
            
            ProgressLineView($progress)
                .padding(.horizontal, 16)
                .frame(width: .infinity, height: 2)
        }
        .background(Views.RoundShadowView(cornerRadidus: 18))
    }
    
    private var editButton: some View {
        Button {
            self.editHandlerWithCopyURL(false)
        } label: {
            Image(systemName: "square.and.pencil")
                .foregroundColor(self.theme.colors.secondaryTitle.asColor)
        }
        .frame(width: 22, height: 22)
    }
    
    private var refreshButton: some View {
        Button {
            self.refreshHandler()
        } label: {
            Image(systemName: "arrow.clockwise.circle.fill")
                .foregroundColor(self.theme.colors.secondaryTitle.asColor)
        }
        .frame(width: 22, height: 22)
    }
    
    private var roundShadow: some View {
        
        let shadowColorAlpha: CGFloat = self.colorScheme == .light ? 0.4 : 0.1
        let shadowColor = UIColor.label.withAlphaComponent(shadowColorAlpha)
        return RoundedRectangle(cornerRadius: 18)
            .fill(self.theme.colors.appBackground.asColor)
            .shadow(color: shadowColor.asColor, radius: 0.1, y: 0.1)
    }
}

private struct InnerWebViewToolbarControlSection: View {
    
    @Binding var isEditable: Bool
    @Binding var isJumpable: Bool
    @Binding var isRewindable: Bool
    @Binding var isForwardable: Bool
    @Binding var isMarkAsRead: Bool
    @Binding var hasNote: Bool
    
    var backwardHandler: () -> Void = { }
    var forwardHandler: () -> Void = { }
    var markAsReadHandler: () -> Void = { }
    var noteHandler: () -> Void = { }
    var jumpHandler: () -> Void = { }
    var safariHandler: () -> Void = { }
    
    var body: some View {
        HStack {
            self.backButton
            Spacer()
            self.forwardButton
            Spacer()
            if isEditable {
                self.readMarkButton
            } else {
                Spacer()
            }
            Spacer()
            if isEditable {
                self.memoButton
            } else {
                Spacer()
            }
            Spacer()
            if isJumpable {
                self.jumpButton
            }
            self.safariButton
        }
        .padding(.horizontal, 16)
    }
    
    private var backButton: some View {
        return Button {
            self.backwardHandler()
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundColor(isRewindable ? theme.colors.accentColor.asColor : theme.colors.raw.lightGray.asColor)
        }
        .disabled(!self.isRewindable)
        .frame(width: 40, height: 40)
    }
    
    private var forwardButton: some View {
        return Button {
            self.forwardHandler()
        } label: {
            Image(systemName: "chevron.right")
                .foregroundColor(isForwardable ? theme.colors.accentColor.asColor : theme.colors.raw.lightGray.asColor)
        }
        .disabled(!self.isForwardable)
        .frame(width: 40, height: 40)
    }
    
    private var readMarkButton: some View {
        return Button {
            self.markAsReadHandler()
        } label: {
            Image(systemName: isMarkAsRead ? "checkmark.circle.fill" : "checkmark.circle")
        }
        .frame(width: 40, height: 40)
    }
    
    private var jumpButton: some View {
        return Button {
            self.jumpHandler()
        } label: {
            Image(systemName: "folder")
        }
        .frame(width: 40, height: 40)
    }
    
    private var memoButton: some View {
        return Button {
            self.noteHandler()
        } label: {
            Image(systemName: hasNote ? "note.text" : "note.text.badge.plus")
        }
        .frame(width: 40, height: 40)
    }
    
    private var safariButton: some View {
        return Button {
            self.safariHandler()
        } label: {
            Image(systemName: "safari")
        }
        .frame(width: 40, height: 40)
    }
}


// MARK: - preview

final class DummyInnerWebViewModel: InnerWebViewViewModel {
    
    func prepareLinkData() {}
    
    func openPageInSafari() { }
    
    func managePageDetail(withCopyURL: Bool) { }
    
    func editMemo() { }
    
    func toggleMarkAsRed() { }
    
    func jumpToCollection() { }
    
    func pageLoaded(for url: String) { }
    
    func saveLastReadPositionIfNeed(_ position: Double) { }
    
    var isEditable: Bool { true }
    
    var isJumpable: Bool { false }
    
    var startLoadWebPage: Observable<WebPageLoadParams> { .just(.init(urlPath: "https://www.naver.com")) }
    
    var urlPageTitle: Observable<String> { .just("Test title") }
    
    var isRed: Observable<Bool> { .just(true) }
    
    var hasMemo: Observable<Bool> { .just(false) }
}

struct InnerWebViewPreview: PreviewProvider {
    
    static var previews: some View {
        let viewModel = DummyInnerWebViewModel()
        return InnerWebView_SwiftUI(viewModel: viewModel)
    }
}
