//
//  AppDelegate.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var window: UIWindow?
    private let rootViewControllerFactory: RootViewControllerFactory = RootDependencyContainerImpl()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        self.configure3rdParties()
        let vc: RootViewController = self.rootViewControllerFactory.makeRootViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        return true
    }
}

// MARK: - Configurations
private extension AppDelegate {
    
    func configure3rdParties() {
        self.configureSimpleLogger()
    }
    
    func configureSimpleLogger() {
        #if DEBUG
        SimpleLogger.setVerbosityLevel(SimpleLogger.Verbosity.all.rawValue)
        #else
        SimpleLogger.setVerbosityLevel(SimpleLogger.Verbosity.none.rawValue)
        #endif
    }
}
