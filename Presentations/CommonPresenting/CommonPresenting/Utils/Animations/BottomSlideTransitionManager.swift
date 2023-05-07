//
//  BottomSlideTransitionManager.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/28.
//

import UIKit


@MainActor
public struct BottomSlideAnimationConstants {
    
    let animationDuration: TimeInterval
    let sliderShowingFrameHeight: CGFloat
    
    private static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    public init(animationDuration: TimeInterval = 0.25,
                sliderShowingFrameHeight: CGFloat? = nil) {
        self.animationDuration = animationDuration
        
        let defaultHeight: () -> CGFloat = {
            return Self.screenSize.height
        }
        self.sliderShowingFrameHeight = sliderShowingFrameHeight ?? defaultHeight()
    }
    
    private var sliderSize: CGSize {
        return .init(width: Self.screenSize.width, height: self.sliderShowingFrameHeight)
    }
    
    var sliderHideFrame: CGRect {
        let origin = CGPoint(x: 0, y: Self.screenSize.height)
        return .init(origin: origin, size: self.sliderSize)
    }
    
    var sliderShowingFrame: CGRect {
        let origin = CGPoint(x: 0, y: Self.screenSize.height - self.sliderShowingFrameHeight)
        return .init(origin: origin, size: self.sliderSize)
    }
}

public final class BottomSlidShowing: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let constant: BottomSlideAnimationConstants
    public init(constant: BottomSlideAnimationConstants) {
        self.constant = constant
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.constant.animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let showingController = transitionContext.viewController(forKey: .to),
              let showingView = showingController.view else {
            return
        }
        let constant = self.constant
        
        let shadowView = ShadowView(frame: UIScreen.main.bounds)
        shadowView.updateDimpercent(0.1)
        transitionContext.containerView.addSubview(shadowView)
        
        transitionContext.containerView.addSubview(showingView)
        
        showingView.frame = constant.sliderHideFrame
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            showingView.frame = constant.sliderShowingFrame
            
            shadowView.updateDimpercent(1.0)
        }, completion: { success in
            shadowView.updateDimpercent(1.0)
            transitionContext.completeTransition(success)
        })
    }
}


public final class BottomSlideHiding: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let constant: BottomSlideAnimationConstants
    public init(constant: BottomSlideAnimationConstants) {
        self.constant = constant
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.constant.animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let slideViewController = transitionContext.viewController(forKey: .from),
              let slideView = slideViewController.view else {
            return
        }
        
        let constant = self.constant
        
        let shadowView = transitionContext.containerView.subviews.first(where: { $0 is ShadowView }) as? ShadowView
        shadowView?.updateDimpercent(1.0)
        
        slideView.frame = constant.sliderShowingFrame
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            slideView.frame = constant.sliderHideFrame
            shadowView?.updateDimpercent(0.1)
        }, completion: { _ in
            if transitionContext.transitionWasCancelled {
                transitionContext.completeTransition(false)
            } else {
                shadowView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        })
    }
}


public final class BottomSlideTransitionAnimationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    public var constant: BottomSlideAnimationConstants!
    
    private let interactor = BottomPullPangestureDismissalInteractor()
    
    public var dismissalInteractor: PangestureDismissalInteractor {
        return interactor
    }
    
    public override init() {
        super.init()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSlideHiding(constant: self.constant ?? .init())
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSlidShowing(constant: self.constant ?? .init())
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.interactor.hasStarted ? self.interactor : nil
    }
}
