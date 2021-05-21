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
    
    var animationDuration: TimeInterval {
        return 0.23
    }
    
    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    var pushingViewShowFrame: CGRect {
        let width = screenSize.width * 0.8
        let origin = CGPoint(x: screenSize.width - width, y: 0)
        return CGRect(origin: origin, size: screenSize)
    }
    
    var pushingViewHideFrame: CGRect {
        let origin = CGPoint(x: screenSize.width, y: 0)
        return CGRect(origin: origin, size: screenSize)
    }
    
    var pushedViewOriginalFrame: CGRect {
        return CGRect(origin: .zero, size: screenSize)
    }
    
    var pushedViewFrame: CGRect {
        let origin = CGPoint(x: -pushingViewShowFrame.width, y: 0)
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
              let pushedController = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let pushingView = pushingController.view
        let pushedView = pushedController.view
        pushingView?.frame = self.pushingViewHideFrame
        pushedView?.frame = self.pushedViewOriginalFrame
        
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            pushingView?.frame = self.pushingViewShowFrame
            pushedView?.frame = self.pushedViewFrame
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
              let pushedController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let pushingView = pushingController.view
        let pushedView = pushedController.view
        pushingView?.frame = self.pushingViewShowFrame
        pushedView?.frame = self.pushedViewFrame
        
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            pushingView?.frame = self.pushingViewHideFrame
            pushedView?.frame = self.pushedViewOriginalFrame
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


public final class PushslideTransitionAnimationManager {
    
    private let interactor: PangestureDismissalInteractor = PangestureDismissalInteractor()
    
    var dismissalInteractor: PangestureDismissalInteractor {
        return interactor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushSlideShowing()
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushSlideHiding()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.interactor.hasStarted ? self.dismissalInteractor : nil
    }
}
