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
import Prelude

import Domain
import CommonPresenting
import WebView
import Extensions


final class InnerWebViewState: ObservableObject {
    
    @Published var isBackwardable: Bool = false
    @Published var isForwardable: Bool = false
    @Published var isEditable = false
    @Published var isJumpable = false
    @Published var startLoadWebPage: WebPageLoadParams?
    @Published var urlPageTitle: String = ""
    @Published var isMarkAsRead: Bool = false
    @Published var hasMemo: Bool = false
    @Published var suggestMoveToLastReadPosition: WebPageLoadParams.LastReadPositionInfo?
    
    @Published var progress: CGFloat = 0.0
    func updatProgress(_ progress: CGFloat) {
        self.cancelResetProgressWithDelay()
        
        self.progress = progress
        guard progress >= 1.0 else { return }
        self.resetProgressWithDelay = Observable<Int>
            .timer(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.progress = 0.0
            })
    }
    
    private func cancelResetProgressWithDelay() {
        self.resetProgressWithDelay?.dispose()
    }
    
    @ObservedObject var webviewStore: WebViewStore = .init()
    @Published var scrollContentOffset: CGPoint = .zero
    @Published var isScrollDown: Bool = false
    var toolbarBottomOffset: CGFloat {
        return self.isScrollDown ? 74 : 0
    }
    
    private let disposeBag = DisposeBag()
    private var cancellables: Set<AnyCancellable> = []
    private var resetProgressWithDelay: Disposable?
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
        
        self.isEditable = viewModel.isEditable
        self.isJumpable = viewModel.isJumpable
        
        let scrollingY = self.$scrollContentOffset.map { $0.y }
            .movingAverageFilter(10)
            .share()
        let scrollYChanges = Publishers.Zip(scrollingY, scrollingY.dropFirst())
        let filterWhenEnoughScrollDown: (CGFloat, CGFloat) -> Bool? = { [weak self] old, new in
            let isDown = (new - old) > 0
            let threshold: CGFloat = 104
            let isDragging = self?.webviewStore.webView.scrollView.isDragging == true
            return isDragging && new > threshold ? isDown : nil
        }
        
        scrollYChanges
            .compactMap(filterWhenEnoughScrollDown)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isDown in
                self?.isScrollDown = isDown
            })
            .store(in: &self.cancellables)
        
        let lastReadPosition = self.$startLoadWebPage.compactMap { $0 }.first()
        let firstLoadDone = self.$progress.filter { $0 >= 1.0 }.first()
        Publishers.CombineLatest(
            lastReadPosition, firstLoadDone
        )
        .sink(receiveValue: { [weak self] params, _ in
            if let info = params.lastReadPosition {
                self?.suggestMoveToLastReadPosition = info
                logger.print(level: .debug, "will show suggest move to last read position, offset: \(info.position)")
            }
            
            self?.bindLastScrollOffset(viewModel)
        })
        .store(in: &self.cancellables)
    }
    
    private func bindLastScrollOffset(_ viewModel: InnerWebViewViewModel) {
        
        let filterIsEnoughScrolled: (CGFloat) -> CGFloat? = { [weak self] y in
            guard let frameHeight = self?.webviewStore.webView.scrollView.frame.size.height,
                    y > frameHeight
            else { return nil }
            return y
        }
        
        self.$scrollContentOffset
            .map { $0.y }
            .compactMap(filterIsEnoughScrolled)
            .removeDuplicates()
            .throttle(for: 5.0, scheduler: RunLoop.main, latest: true)
            .sink(receiveValue: { offsetY in
                viewModel.saveLastReadPositionIfNeed(offsetY)
            })
            .store(in: &self.cancellables)
    }
}


public struct InnerWebView_SwiftUI: View {
    
    private let viewModel: InnerWebViewViewModel
    @StateObject private var state: InnerWebViewState = .init()
    
    public init(viewModel: InnerWebViewViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            Views.PullGuideView()
                .cornerRadius(10, corners: [.topLeft, .topRight])
                
            ZStack {
                
                WebView(webView: state.webviewStore.webView)
                    .onReceive(state.$startLoadWebPage) { params in
                        guard let params = params,
                              let url = URL(string: params.urlPath)
                        else { return }
                        self.state.webviewStore.webView.load(URLRequest(url: url))
                    }
                    .onReceive(state.webviewStore.webView.publisher(for: \.scrollView.contentOffset)) { offset in
                        self.state.scrollContentOffset = offset
                    }
                    .onReceive(state.webviewStore.webView.publisher(for: \.estimatedProgress)) { progress in
                        self.state.updatProgress(progress)
                        if progress >= 1.0 {
                            self.updateWebViewNavigationButtons()
                        }
                    }
                    .onReceive(state.webviewStore.webView.publisher(for: \.url)) { url in
                        if let urlPath = url?.absoluteString { self.viewModel.pageLoaded(for: urlPath) }
                        self.updateWebViewNavigationButtons()
                    }
                
                GeometryReader { metrics in
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .center) {
                            if let lastPosition = self.state.suggestMoveToLastReadPosition {
                                self.moveToLastReadPositionView(lastPosition)
                                    .frame(width: metrics.size.width * 0.7)
                            }
                         
                            VStack {
                                
                                Divider()
                                
                                InnerWebViewToolbarInfoSection(
                                    title: $state.urlPageTitle,
                                    isEditable: $state.isEditable,
                                    progress: $state.progress,
                                    isShrinkMode: $state.isScrollDown
                                )
                                .eventHandler(\.editHandlerWithCopyURL, viewModel.managePageDetail(withCopyURL:))
                                .eventHandler(\.refreshHandler) {
                                    guard self.state.webviewStore.webView.isLoading == false else { return }
                                    self.state.webviewStore.webView.reload()
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
                                    guard self.state.webviewStore.webView.canGoBack == true else { return }
                                    self.state.webviewStore.webView.goBack()
                                }
                                .eventHandler(\.forwardHandler) {
                                    guard self.state.webviewStore.canGoForward == true else { return }
                                    self.state.webviewStore.webView.goForward()
                                }
                                .eventHandler(\.markAsReadHandler, viewModel.toggleMarkAsRed)
                                .eventHandler(\.noteHandler, viewModel.editMemo)
                                .eventHandler(\.jumpHandler, viewModel.jumpToCollection)
                                .eventHandler(\.safariHandler, viewModel.openPageInSafari)
                            }
                            .background(VisualEffectView().ignoresSafeArea(edges: [.bottom]))
                        }
                        .offset(.init(width: 0, height: self.state.toolbarBottomOffset))
                        .animation(.easeIn(duration: 0.4), value: self.state.toolbarBottomOffset)
                    }
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
        let forwardCount = state.webviewStore.webView.backForwardList.forwardList.count
        let backwardCount = state.webviewStore.webView.backForwardList.backList.count
        self.state.isBackwardable = backwardCount > 0
        self.state.isForwardable = forwardCount > 0
    }
    
    private func moveToLastReadPositionView(
        _ info: WebPageLoadParams.LastReadPositionInfo
    ) -> some View {
        return Views.BaseFloatingButton(
            title: "reading-option-ask-last-position".localized,
            description: info.savedAt
        )
        .eventHandler(\.mainActionHandler) {
            self.moveScrollToLastReadPosition(info.position)
        }
        .eventHandler(\.closeActionHandler) {
            withAnimation {
                self.state.suggestMoveToLastReadPosition = nil
            }
        }
    }
    
    private func moveScrollToLastReadPosition(_ offset: Double) {
        logger.print(level: .debug, "will move to last read position to: \(offset) and webView content size: \(self.state.webviewStore.webView.scrollView.contentSize)")
        
        let lastPoint = CGPoint(x: 0, y: CGFloat(offset))
        self.state.webviewStore.webView.scrollView
            .setContentOffset(lastPoint, animated: false)
        withAnimation {
            self.state.suggestMoveToLastReadPosition = nil
        }
    }
}


private struct InnerWebViewToolbarInfoSection: View {
    
    @Binding var title: String
    @Binding var isEditable: Bool
    @Binding var progress: CGFloat
    @Binding var isShrinkMode: Bool
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var editHandlerWithCopyURL: (Bool) -> Void = { _ in }
    var refreshHandler: () -> Void = { }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                
                if self.isEditable {
                    self.editButton
                        .opacity(self.isShrinkMode ? 0.0 : 1.0)
                }
                
                Spacer()
                Text(self.title)
                    .lineLimit(1)
                    .foregroundColor(self.theme.colors.text.withAlphaComponent(0.8).asColor)
                    .font(self.theme.fonts.get(12, weight: .regular).asFont)
                    .onTapGesture {
                        self.editHandlerWithCopyURL(true)
                    }
                    .offset(.init(width: 0, height: self.isShrinkMode ? -12 : 0))
                Spacer()
                
                self.refreshButton
                    .opacity(self.isShrinkMode ? 0.0 : 1.0)
            }
            .padding([.horizontal], 16)
            .padding([.vertical], 7)
            
            ProgressLineView($progress)
                .padding(.horizontal, 16)
                .frame(height: 2)
        }
        .background(
            Views.RoundShadowView(cornerRadidus: 18).opacity(self.isShrinkMode ? 0.0 : 1.0)
        )
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
                .frame(width: 40, height: 40)
        }
        .disabled(!self.isRewindable)
    }
    
    private var forwardButton: some View {
        return Button {
            self.forwardHandler()
        } label: {
            Image(systemName: "chevron.right")
                .foregroundColor(isForwardable ? theme.colors.accentColor.asColor : theme.colors.raw.lightGray.asColor)
                .frame(width: 40, height: 40)
        }
        .disabled(!self.isForwardable)
    }
    
    private var readMarkButton: some View {
        return Button {
            self.markAsReadHandler()
        } label: {
            Image(systemName: isMarkAsRead ? "checkmark.circle.fill" : "checkmark.circle")
                .frame(width: 40, height: 40)
        }
    }
    
    private var jumpButton: some View {
        return Button {
            self.jumpHandler()
        } label: {
            Image(systemName: "folder")
                .frame(width: 40, height: 40)
        }
    }
    
    private var memoButton: some View {
        return Button {
            self.noteHandler()
        } label: {
            Image(systemName: hasNote ? "note.text" : "note.text.badge.plus")
                .frame(width: 40, height: 40)
        }
    }
    
    private var safariButton: some View {
        return Button {
            self.safariHandler()
        } label: {
            Image(systemName: "safari")
                .frame(width: 40, height: 40)
        }
    }
}

private struct Buffer {
    let outputs: [CGFloat]
    var averaged: CGFloat? {
        guard outputs.isNotEmpty else { return nil }
        return outputs.reduce(0, +) / CGFloat(outputs.count)
    }
    
    func appended(_ newOutput: CGFloat, size: Int) -> Buffer {
        return Buffer(outputs: (self.outputs + [newOutput]).suffix(size))
    }
}

private extension Publisher where Output == CGFloat {
    
    func movingAverageFilter(_ size: Int) -> some Publisher<Output, Failure> {
        let buffered = self.scan(Buffer(outputs: [])) { acc, output in acc.appended(output, size: size) }
        return buffered
            .compactMap { $0.averaged }
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
