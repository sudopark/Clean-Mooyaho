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

import FirebaseService


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var applicationViewModel: ApplicationViewModel!
    private let diContainers: DIContainers
    private let firebaseService: FirebaseService = FirebaseService()
    
    private let disposeBag = DisposeBag()
    
    override init() {
        self.diContainers = DIContainers()
        let router = ApplicationRootRouter(nextSceneBuilders: self.diContainers)
        self.applicationViewModel = ApplicationViewModel(router: router)
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.firebaseService.setup()
        self.firebaseService.signInAnonymously()
        
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//
//        let viewController = ViewController()
//        self.window?.rootViewController = viewController
//        self.window?.makeKeyAndVisible()
        
        self.applicationViewModel.appDidLaunched()
        return true
    }
}
