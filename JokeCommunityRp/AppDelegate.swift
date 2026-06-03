//
//  AppDelegate.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit
import IQKeyboardManager
import Toast_Swift
@_exported import SnapKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        ToastManager.shared.position = .center
        
        initializeWindow()
        
        return true
    }

    private func initializeWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        JC_CurrentUser.shared.restoreSession()
        if JC_CurrentUser.shared.isLoggedIn {
            JC_CurrentUser.shared.showMainInterface(in: window)
        } else {
            JC_CurrentUser.shared.showWelcomeInterface(in: window)
        }
        window?.makeKeyAndVisible()
    }

}

