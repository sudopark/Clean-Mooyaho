//
//  AppDelegate.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    private var applicationRouter: ApplicationRouter!
    private let firebaseService: FirebaseService = FirebaseService()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let dependency = ApplicationDIContainer()
        self.applicationRouter = ApplicationRouter(DI: dependency)
        
        if AppEnvironment.buildMode == .test {
            return true
        }

        self.firebaseService.setup()
        self.firebaseService.signInAnonymously()
        
        
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//
//        let viewController = ViewController()
//        self.window?.rootViewController = viewController
//        self.window?.makeKeyAndVisible()
        return true
    }
}
