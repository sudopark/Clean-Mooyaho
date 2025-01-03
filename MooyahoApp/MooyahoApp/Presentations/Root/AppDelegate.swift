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

import Domain
import CommonPresenting
import Extensions


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var applicationViewModel: ApplicationViewModel!
    let dependencyInjector: DependencyInjector
    
    private let disposeBag = DisposeBag()
    
    override init() {
        self.dependencyInjector = DependencyInjector()
        
        logger.attachCrashLogger(self.dependencyInjector.shared.crashLogger)
        
        let router = ApplicationRootRouter(nextSceneBuilders: self.dependencyInjector)
        let usecase = self.dependencyInjector.applicationUsecase
        let shareUsecase = self.dependencyInjector.shareItemUsecase
        self.applicationViewModel = ApplicationViewModelImple(applicationUsecase: usecase,
                                                              shareCollectionHandleUsecase: shareUsecase,
                                                              firebaseService: self.dependencyInjector.firebaseService,
                                                              fcmService: self.dependencyInjector.fcmService,
                                                              kakaoService: self.dependencyInjector.shared.kakaoService,
                                                              router: router)
        UIContext.register(UIContext(theme: DefaultTheme()))
        SwiftUITheme.theme = DefaultTheme()
        UIContext.updateApp(status: .launched)
        
        super.init()
        self.bind(usecase)
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.applicationViewModel.appDidLaunched()
        return true
    }
    
    private func bind(_ usecase: ApplicationUsecase) {
        
        usecase.currentSignedInMemeber
            .map { $0?.uid }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] uid in
                self?.dependencyInjector.remote.signInMemberID = uid
            })
            .disposed(by: self.disposeBag)
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
        UIContext.updateApp(status: .background)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.applicationViewModel.appWillEnterForground()
        UIContext.updateApp(status: .forground)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.applicationViewModel.appWillTerminate()
        UIContext.updateApp(status: .terminate)
    }
}


// MARK: - handle notification

extension AppDelegate {
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.applicationViewModel.apnsTokenUpdated(deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.print(level: .error, "fail to register remote notification: \(error)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.applicationViewModel.newPushMessageRecived(userInfo)
        completionHandler(.noData)
    }
}


// MARK: - handle URL

extension AppDelegate {
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.applicationViewModel.handleOpenURL(url: url, options: options)
    }
}
