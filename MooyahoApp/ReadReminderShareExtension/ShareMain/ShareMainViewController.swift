//
//  ShareMainViewController.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/10/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting
import FirebaseService

// MARK: - ShareMainViewController

@MainActor
final class ShareExtensionRoot {
    
    let injector = SharedDependencyInjecttor()
    private let disposeBag = DisposeBag()
    
    init() {
        self.injector.shared.firebaseServiceImple.setupService()
        self.bindAuth()
    }
    
    func setupService() {
        self.injector.shared.firebaseServiceImple.setupService()
    }
    
    var mainRouter: ShareMainRouter {
        
        return ShareMainRouter(nextSceneBuilders: self.injector)
    }
    
    private func bindAuth() {
        
        self.injector.memberUsecase.currentMember
            .map { $0?.uid }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] memberID in
                self?.injector.remote.signInMemberID = memberID
            })
            .disposed(by: self.disposeBag)
    }
}

@MainActor let extensionRoot = ShareExtensionRoot()

@objc(ShareMainViewController)
public final class ShareMainViewController: BaseViewController, ShareMainScene {
    
    var viewModel: ShareMainViewModel!
    
    private func makeViewModel() -> ShareMainViewModel {
        let router = extensionRoot.mainRouter
        let viewModel = ShareMainViewModelImple(
            authUsecase: extensionRoot.injector.authUsecase,
            readItemSyncUsecase: extensionRoot.injector.readItemUsecase,
            router: router,
            listener: nil
        )
        router.currentScene = self
        
        return viewModel
    }
    
    public override func loadView() {
        super.loadView()
        self.setupLayout()
        self.setupStyling()
        self.viewModel = self.makeViewModel()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
        self.requestShowEditLink()
    }
    
    private func requestShowEditLink() {
        guard let items = self.extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = items.attachments?.first,
              provider.hasItemConformingToTypeIdentifier("public.url") == true
        else {
            self.finishShare()
            return
        }
        
        provider.loadItem(forTypeIdentifier: "public.url") { string, error in
            let urlAddress = (string as? URL)?.absoluteString ?? (string as? String)
            Task { @MainActor in
                guard let url = urlAddress else {
                    self.finishShare()
                    return
                }
                self.viewModel.showEditScene(url)
            }
        }
    }
}

// MARK: - bind

extension ShareMainViewController {
    
    private func bind() {
        
        self.viewModel.finishSharing
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.finishShare()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func finishShare() {
        
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}

// MARK: - setup presenting

extension ShareMainViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        self.view.backgroundColor = .clear
    }
}
