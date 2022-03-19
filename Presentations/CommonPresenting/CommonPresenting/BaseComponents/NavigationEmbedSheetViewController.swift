//
//  NavigationEmbedSheetViewController.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/03/18.
//

import UIKit


public protocol NavigationEmbedSheet: UIViewController {
    
    func updateHeight(_ contentHeight: CGFloat)
}

public final class NavigationEmbedSheetViewController: BaseViewController, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let containerView = UIView()
    public let embedNavigationController: UINavigationController = BaseNavigationController(shouldHideNavigation: false, shouldShowCloseButtonIfNeed: true)
    // TODO: 추후에 가변적으로 높이 변경할수있으면 변경
    private var embedNavigationHeightConstraint: NSLayoutConstraint!
    
    private let startContentHeight: CGFloat
    
    public init(startContentHeight: CGFloat = 450) {
        self.startContentHeight = startContentHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        self.setupLayout()
        self.setupStyling()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.embedNavigation()
    }
    
    public func requestCloseScene() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NavigationEmbedSheetViewController {
    
    private func embedNavigation() {
        
        self.addChild(self.embedNavigationController)
        self.bottomSlideMenuView.containerView.addSubview(embedNavigationController.view)
        embedNavigationController.view.autoLayout.fill(bottomSlideMenuView.containerView)
        self.embedNavigationHeightConstraint = embedNavigationController.view.heightAnchor.constraint(equalToConstant: self.startContentHeight)
        self.embedNavigationHeightConstraint.isActive = true
        embedNavigationController.didMove(toParent: self)
    }
}

extension NavigationEmbedSheetViewController: Presenting {
    
    public func setupLayout() {
        self.setupBottomSlideLayout()
    }
    
    public func setupStyling() {
        self.bottomSlideMenuView.setupStyling()
    }
}

