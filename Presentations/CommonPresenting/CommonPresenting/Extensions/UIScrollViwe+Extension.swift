//
//  UIScrollViwe+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/03.
//

import UIKit

import RxSwift
import RxCocoa


extension Reactive where Base: UIScrollView {
    
    public func scrollBottomHit(wait: Observable<Void>,
                                threshold: CGFloat = 0,
                                throttleTimeMillis: Int = 1000) -> Observable<Void> {
        
        return self.contentOffset
            .skip(until: wait)
            .distinctUntilChanged()
            .map{ $0.y <= threshold }
            .distinctUntilChanged()
            .filter{ $0 }
            .throttle(.milliseconds(throttleTimeMillis), scheduler: MainScheduler.instance)
            .map{ _ in }
    }
}
