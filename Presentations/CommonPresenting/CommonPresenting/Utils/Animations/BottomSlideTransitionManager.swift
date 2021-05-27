//
//  BottomSlideTransitionManager.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/28.
//

import UIKit


public protocol ScrollingEmbeding {
    
    var scrollView: UIScrollView { get }
}

public final class BottomSlidShowing: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // TODO: inject
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let showingController = transitionContext.viewController(forKey: .to),
              let showingView = showingController.view else {
            return
        }
        
        transitionContext.containerView.addSubview(showingView)
        
        // TODO: inject
        let screenSize = UIScreen.main.bounds.size
        let defaultHeight = screenSize.height - 20
        let hideFrame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: defaultHeight)
        showingView.frame = hideFrame
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            let showOriginY = screenSize.height - 40
            let showingFrame = CGRect(x: 0, y: showOriginY, width: screenSize.width, height: defaultHeight)
            showingView.frame = showingFrame
            
        }, completion: { success in
            transitionContext.completeTransition(success)
        })
    }
}


public final class BottomSlideHiding: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // TODO: inject
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let slideViewController = transitionContext.viewController(forKey: .from),
              let slideView = slideViewController.view else {
            return
        }
        
        let screenSize = UIScreen.main.bounds.size
        let defaultHeight = screenSize.height - 20
        let showOriginY = screenSize.height - 40
        let showingFrame = CGRect(x: 0, y: showOriginY, width: screenSize.width, height: defaultHeight)
        slideView.frame = showingFrame
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            let hideFrame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: defaultHeight)
            slideView.frame = hideFrame
        }, completion: { _ in
            transitionContext.completeTransition(transitionContext.transitionWasCancelled == false)
        })
    }
}


public final class BottomSlideTransitionAnimationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    public override init() {}
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSlideHiding()
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSlidShowing()
    }
}
