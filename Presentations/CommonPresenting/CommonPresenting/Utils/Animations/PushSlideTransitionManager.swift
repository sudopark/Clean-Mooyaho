//
//  PushSlideTransitionManager.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit


// MARK: PushSlide animation constants

public protocol PushSlideAnimationConstants { }

extension PushSlideAnimationConstants {
    
    var contentRatio: CGFloat { 0.8 }
    
    var animationDuration: TimeInterval { 0.25 }
    
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    private var pushingViewContentSize: CGSize {
        return CGSize(width: self.screenSize.width * self.contentRatio, height: self.screenSize.height)
    }
    
    var pushingViewShowFrame: CGRect {
        return .init(origin: .zero, size: self.screenSize)
    }
    
    var pushingViewHideFrame: CGRect {
        let origin = CGPoint(x: self.pushingViewContentSize.width, y: 0)
        return .init(origin: origin, size: self.screenSize)
    }
    
    var originViewFrame: CGRect {
        return CGRect(origin: .zero, size: screenSize)
    }
    
    var originViewMovedFrame: CGRect {
        let origin = CGPoint(x: -pushingViewContentSize.width, y: 0)
        return CGRect(origin: origin, size: screenSize)
    }
}


// MARK: - PushSlide showing + hiding animations

public final class PushSlideShowing: NSObject, UIViewControllerAnimatedTransitioning, PushSlideAnimationConstants {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let pushingController = transitionContext.viewController(forKey: .to),
              let originViewController = transitionContext.viewController(forKey: .from),
              let pushingView = pushingController.view,
              let originView = originViewController.view else {
            return
        }
        
        transitionContext.containerView.addSubview(pushingView)
        
        pushingView.frame = self.pushingViewHideFrame
        originView.frame = self.originViewFrame
        
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            pushingView.frame = self.pushingViewShowFrame
            originView.frame = self.originViewMovedFrame
        }, completion: { success in
            transitionContext.completeTransition(success)
        })
    }
}

public final class PushSlideHiding: NSObject, UIViewControllerAnimatedTransitioning, PushSlideAnimationConstants {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let pushingController = transitionContext.viewController(forKey: .from),
              let originViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let pushingView = pushingController.view
        let originView = originViewController.view
        pushingView?.frame = self.pushingViewShowFrame
        originView?.frame = self.originViewMovedFrame
        
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            pushingView?.frame = self.pushingViewHideFrame
            originView?.frame = self.originViewFrame
        }, completion: { _ in
            if transitionContext.transitionWasCancelled {
                transitionContext.completeTransition(false)
            } else {
                pushingView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        })
    }
}


public final class PushslideTransitionAnimationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    private let interactor = RightSwipePangestureDismissalInteractor()
    
    public override init() { }
    
    public var dismissalInteractor: PangestureDismissalInteractor {
        return interactor
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushSlideHiding()
    }
    
    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushSlideShowing()
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.interactor.hasStarted ? self.dismissalInteractor : nil
    }
}
