//
//  UIScrollViwe+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/03.
//

import UIKit

import RxSwift
import RxCocoa


extension UIScrollView {
    
    public var verticalScrollableHeight: CGFloat {
        let height = self.contentSize.height - self.frame.height + self.contentInset.top + self.contentInset.bottom
        return max(height, 0)
    }
}

extension Reactive where Base: UIScrollView {
    
    public func scrollBottomHit(wait: Observable<Void>,
                                threshold: CGFloat = 0,
                                throttleTimeMillis: Int = 1000) -> Observable<Void> {
        
        return self.contentOffset
            .skip(until: wait)
            .compactMap { [weak base] offset -> Bool? in
                guard let base = base else { return nil }
                return base.verticalScrollableHeight - threshold <= offset.y
            }
            .distinctUntilChanged()
            .filter{ $0 }
            .throttle(.milliseconds(throttleTimeMillis), scheduler: MainScheduler.instance)
            .map{ _ in }
    }
}
