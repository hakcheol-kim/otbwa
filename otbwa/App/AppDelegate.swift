//
//  AppDelegate.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/29.
//

import UIKit
import Firebase

let appDelegate = UIApplication.shared.delegate as! AppDelegate
var isEdgePhone = {
    return (appDelegate.window?.safeAreaInsets.bottom)! > 0.0
}()
@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var mainTabBarCtrl: MainTabBarController!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        FirebaseApp.configure()
        window?.overrideUserInterfaceStyle = .light

        callLoginVc()
        return true
    }
    
    func callLoginVc() {
        let vc = LoginViewController.instantiateFromStoryboard(.login)!
        let navi = BaseNavigationController.init(rootViewController: vc)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
    }
    
    func calllMainVc() {
        self.mainTabBarCtrl = MainTabBarController.instantiateFromStoryboard(.main)!
        window?.rootViewController = mainTabBarCtrl
        window?.makeKeyAndVisible()
    }
}

