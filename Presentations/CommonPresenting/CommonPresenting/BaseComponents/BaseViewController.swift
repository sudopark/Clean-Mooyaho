//
//  BaseViewController.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import Domain


open class BaseViewController: UIViewController, UIContextAccessable {
    
    public let disposeBag: DisposeBag = DisposeBag()
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.print(level: .debug, "will Appear -> \(String(describing: Self.self))")
    }
}
