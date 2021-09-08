//
//  AppDelegate.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/29.
//

import UIKit
import Firebase
import SwiftyJSON
let appDelegate = UIApplication.shared.delegate as! AppDelegate
var isEdgePhone = {
    return (appDelegate.window?.safeAreaInsets.bottom)! > 0.0
}()
@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadingView: UIView?
    var mainNaviCtrl: BaseNavigationController!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        FirebaseApp.configure()
        self.registApnsPushKey()
        window?.overrideUserInterfaceStyle = .light

        //최초 디바이스 키없으면
        let unique = KeychainItem.currentUserIdentifier.lowercased()
        if unique.isEmpty == true {
            let uuid = UIDevice.current.identifierForVendor?.uuidString
            KeychainItem.saveUserInKeychain(uuid!.lowercased()) //키체인 저장
        }

        self.callIntroVc()
        return true
    }
    func callIntroVc() {
        let vc = IntroViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    func callLoginVc() {
        let vc = LoginViewController.instantiateFromStoryboard(.login)!
        let navi = BaseNavigationController.init(rootViewController: vc)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
    }
    
    func calllWsaleMainVc() {
        let vc = WMainTabBarController.init()
        self.mainNaviCtrl = BaseNavigationController.init(rootViewController: vc)
        window?.rootViewController = mainNaviCtrl
        window?.makeKeyAndVisible()
    }
    
    func callRetailMainVc() {
        let vc = RMainTabViewController.instantiateFromStoryboard(.main)!
        self.mainNaviCtrl = BaseNavigationController.init(rootViewController: vc)
        window?.rootViewController = mainNaviCtrl
        window?.makeKeyAndVisible()
    }
    public func startIndicator() {
        DispatchQueue.main.async {
            if let loadingView = appDelegate.window!.viewWithTag(215000) {
                loadingView.removeFromSuperview()
            }
            
            self.loadingView = UIView(frame: UIScreen.main.bounds)
            self.window!.addSubview(self.loadingView!)
            self.loadingView?.tag = 215000
            self.loadingView?.backgroundColor = RGBA(0, 0, 0, 0.1)
            
            let ivLoading = UIActivityIndicatorView()
            self.loadingView?.addSubview(ivLoading)
            ivLoading.translatesAutoresizingMaskIntoConstraints = false
            
            ivLoading.centerXAnchor.constraint(equalTo: self.loadingView!.centerXAnchor).isActive = true
            ivLoading.centerYAnchor.constraint(equalTo: self.loadingView!.centerYAnchor).isActive = true
            ivLoading.heightAnchor.constraint(equalToConstant: 50).isActive = true
            ivLoading.widthAnchor.constraint(equalToConstant: 50).isActive = true
            ivLoading.color = UIColor(named: "AccentColor")
            ivLoading.style = .medium
            ivLoading.startAnimating()
            ivLoading.tag = 215001
            //혹시라라도 indicator 계속 돌고 있으면 강제로 제거 해준다. 10초후에
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+60) {
                if let loadingView = appDelegate.window!.viewWithTag(215000) {
                    ivLoading.stopAnimating()
                    loadingView.removeFromSuperview()
                }
            }
        }
    }
    public func stopIndicator() {
        DispatchQueue.main.async(execute: {
            guard let loadingView = self.loadingView else {
                return
            }
            guard let ivLoading = loadingView.viewWithTag(215001) as? UIActivityIndicatorView else {
                return
            }
            ivLoading.stopAnimating()
            loadingView.removeFromSuperview()
        })
    }
    
    func openUrl(_ url:String, completion: ((_ success:Bool) -> Void)?) {
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let requestUrl = URL.init(string: encodedUrl) else {
            completion?(false)
            return
        }
        UIApplication.shared.open(requestUrl, options: [:]) { (success) in
            completion?(success)
        }
    }
    func removeApnsPushKey() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        Messaging.messaging().delegate = nil
    }
    func registApnsPushKey() {
        self.removeApnsPushKey()
        Messaging.messaging().delegate = self
        self.registerForRemoteNoti()
    }
    func registerForRemoteNoti() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted: Bool, error:Error?) in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func setPushData(_ userInfo:[String:Any], _ isBackgroundMode:Bool = false) {
        let userInfo = JSON(userInfo)
        print("push data: \(userInfo)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //앱이 켜진상태, Forground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard let userInfo = notification.request.content.userInfo as? [String:Any] else {
            return
        }
        
        self.setPushData(userInfo, false)
        print("push data willPresent: ==== \(userInfo)")
        print("categoryIdentifier: \(notification.request.content.categoryIdentifier)")
        completionHandler([.badge, .sound])
    }
    
    //앱이 백그라운드 들어갔을때 푸쉬온것을 누르면 여기 탄다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        defer { completionHandler() }
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            return
        }
        let content = response.notification.request.content
        print("push data didReceive: ==== \(content)")
        print("title: \(content.title)")
        print("body: \(content.body)")
        
        if let userInfo = content.userInfo as? [String:Any] {
            self.setPushData(userInfo, true)
        }
    }
    
}
extension AppDelegate: MessagingDelegate {
    func requestUpdateFcmToken() {
        let userNo = ShareData.ins.userNo
        guard let fcmToken = Messaging.messaging().fcmToken, userNo > 0 else {
            return
        }
        let param:[String:Any] = ["new_token":fcmToken, "user_no": userNo]
        ApiManager.ins.requestUpdateFcmToken(param) { res in
            if res["success"].boolValue {
                print("fcm upload success")
            }
            else {
                self.window?.makeToast("fcm token update error")
            }
        } fail: { error in
            self.window?.makeToast("fcm token update error")
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("==== fcm token key not receive")
            return
        }
        self.requestUpdateFcmToken()
    }
}
