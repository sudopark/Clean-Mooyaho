//
//  Rx+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit

import RxSwift
import RxCocoa



extension Reactive where Base: UIViewController {
    
    @MainActor
    public var viewDidLoad: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidLoad))
    }
    
    @MainActor
    public var viewWillAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillAppear(_:)))
    }
    
    @MainActor
    public var viewDidAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidAppear(_:)))
    }
    
    @MainActor
    public var viewWillLayoutSubviews: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillLayoutSubviews))
    }
    
    @MainActor
    public var viewDidLayoutSubviews: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidLayoutSubviews))
    }
    
    @MainActor
    public var viewWillTransition: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillTransition(to:with:)))
    }
    
    @MainActor
    public var viewWillDisappear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
    }
    
    @MainActor
    public var viewDidDisappear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
    }
}


extension Reactive where Base: UIView {
    
    @MainActor
    public func addTapgestureRecognizer(count: Int = 1,
                                        with impactStyle: FeedbackImapctStyle? = nil) -> Observable<UITapGestureRecognizer> {
        self.base.isUserInteractionEnabled = true
        let existingTapGesture = self.base.gestureRecognizers?.filter{ $0 is UITapGestureRecognizer }
        existingTapGesture?.forEach {
            self.base.removeGestureRecognizer($0)
        }
        
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTouchesRequired = count
        self.base.addGestureRecognizer(gesture)
        
        let runFeedbackOrNot: (UITapGestureRecognizer) -> Void = { [weak base] _ in
            guard let style = impactStyle else { return }
            base?.providerFeedbackImpact(with: style)
        }
        
        return gesture.rx.event
            .do(onNext: runFeedbackOrNot)
            .asObservable()
    }
}


extension Reactive where Base: UIButton {
    
    public func throttleTap(_ time: RxTimeInterval = .milliseconds(800)) -> Observable<Void> {
        return base.rx.tap
            .throttle(time, scheduler: MainScheduler.instance)
    }
}
