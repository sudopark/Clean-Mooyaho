//
//  AppDelegate.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var applicationViewModel: ApplicationViewModel!
    private let diContainers: DIContainers
    
    private let disposeBag = DisposeBag()
    
    override init() {
        self.diContainers = DIContainers()
        let router = ApplicationRootRouter(nextSceneBuilders: self.diContainers)
        self.applicationViewModel = ApplicationViewModel(firebaseService: self.diContainers.shared.firebaseService,
                                                         kakaoService: self.diContainers.shared.kakaoService,
                                                         router: router)
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.applicationViewModel.appDidLaunched()
        
        let serverKey = AppEnvironment.firebaseServiceKey
        print("😾 firebase serverKey: \(serverKey)")
        return true
    }
}


// MARK: - handle application lifeCycle

extension AppDelegate {
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}


// MARK: - handle URL

extension AppDelegate {
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.applicationViewModel.handleOpenURL(url: url, options: options)
    }
}
