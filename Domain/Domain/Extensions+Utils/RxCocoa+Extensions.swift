//
//  RxCocoa+Extensions.swift
//  Domain
//
//  Created by sudo.park on 2021/10/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa



extension Reactive where Base: UIButton {
    
    public func throttleTap(_ time: TimeInterval = 800) -> Observable<Void> {
        return base.rx.tap
            .throttle(.milliseconds(Int(time * 1000)), scheduler: MainScheduler.instance)
    }
}