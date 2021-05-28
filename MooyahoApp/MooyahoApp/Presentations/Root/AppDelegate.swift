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

import CommonPresenting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var applicationViewModel: ApplicationViewModel!
    let diContainers: DIContainers
    
    private let disposeBag = DisposeBag()
    
    override init() {
        self.diContainers = DIContainers()
        let router = ApplicationRootRouter(nextSceneBuilders: self.diContainers)
        let usecase = self.diContainers.applicationUsecase
        self.applicationViewModel = ApplicationViewModelImple(applicationUsecase: usecase,
                                                              firebaseService: self.diContainers.firebaseService,
                                                              kakaoService: self.diContainers.shared.kakaoService,
                                                              router: router)
        UIContext.register(UIContext(theme: DefaultTheme()))
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.applicationViewModel.appDidLaunched()
        return true
    }
}


// MARK: - handle application lifeCycle

extension AppDelegate {
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.applicationViewModel.appDidBecomeActive()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.applicationViewModel.appWillResignActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.applicationViewModel.appDidEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.applicationViewModel.appWillEnterForground()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.applicationViewModel.appWillTerminate()
    }
}


// MARK: - handle URL

extension AppDelegate {
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.applicationViewModel.handleOpenURL(url: url, options: options)
    }
}
