//
//  SIdebarTransitionAnimationManager.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit


// MARK: - SidebarShadow

final class ShadowView: BaseUIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = self.context.colors.raw.black.withAlphaComponent(0.5)
        self.alpha = 0.0
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDimpercent(_ percent: CGFloat) {
        self.alpha = percent
        let shouldHide = percent == 0
        self.isHidden = shouldHide
    }
}


// MARK: - Sidebar animation constants

public protocol SidebarAnimationConstants { }

extension SidebarAnimationConstants {
    
    var animationDuration: TimeInterval {
        return 0.23
    }
    
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    private var drawerContentSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        return CGSize(width: screenSize.width * 0.8, height: screenSize.height)
    }
    
    private var showingOrigin: CGPoint {
        return CGPoint(x: .zero, y: 0)
    }
    
    private var hidingOrigin: CGPoint {
        return CGPoint(x: screenSize.width, y: 0)
    }
    
    var showingFrame: CGRect {
        return CGRect(origin: showingOrigin, size: screenSize)
    }
    
    var hidingFrame: CGRect {
        return CGRect(origin: hidingOrigin, size: screenSize)
    }
}


// MARK: - sidebar showing + hiding animations

public final class SidebarShowing: NSObject, UIViewControllerAnimatedTransitioning, SidebarAnimationConstants {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let sidebarController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let shadow = ShadowView()
        shadow.updateDimpercent(0.1)
        transitionContext.containerView.addSubview(shadow)
        transitionContext.containerView.addSubview(sidebarController.view)
        
        let sidebarView = sidebarController.view
        sidebarView?.frame = self.hidingFrame
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            sidebarView?.frame = self.showingFrame
            shadow.alpha = 1.0
        }, completion: { success in
            shadow.updateDimpercent(1.0)
            transitionContext.completeTransition(success)
        })
    }
}

public final class SidebarHiding: NSObject, UIViewControllerAnimatedTransitioning, SidebarAnimationConstants {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let sidebarController = transitionContext.viewController(forKey: .from) else {
            return
        }
        let shadow = transitionContext.containerView.subviews.first(where: { $0 is ShadowView }) as? ShadowView
        shadow?.updateDimpercent(1.0)
        
        let sidebarView = sidebarController.view
        sidebarView?.frame = showingFrame
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            sidebarView?.frame = self.hidingFrame
            shadow?.updateDimpercent(0.1)
        }, completion: { _ in
            if transitionContext.transitionWasCancelled {
                transitionContext.completeTransition(false)
            } else {
                sidebarView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        })
    }
}


public final class SidebarTransitionAnimationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    private let interactor: PangestureDismissalInteractor = PangestureDismissalInteractor()
    
    public override init() {}
    
    public var dismissalInteractor: PangestureDismissalInteractor {
        return interactor
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidebarHiding()
    }
    
    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidebarShowing()
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.interactor.hasStarted ? self.dismissalInteractor : nil
    }
}
