//
//  IntroViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class IntroViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
            
        let isAuto = UserDefaults.standard.bool(forKey: Dfskey.autoLogin)
        if let id = UserDefaults.standard.object(forKey: Dfskey.userId) as? String,
           let pw = UserDefaults.standard.object(forKey: Dfskey.userPw) as? String,
           isAuto == true {
            
            var param = [String:Any]()
            param["id"] = id
            param["pw"] = pw
            let unique = KeychainItem.currentUserIdentifier
            param["unique"] = unique
            let uuid = UIDevice.current.identifierForVendor?.uuidString
            param["uuid"] = uuid!.lowercased()
            
            ApiManager.ins.requestSingin(param) { res in
                let success = res["success"].boolValue
                let data = res["data"]
                
                if success && data.isEmpty == false {
                    ShareData.ins.userId = id
                    ShareData.ins.userPw = pw
                    ShareData.ins.setUserInfo(data)
                    
                    if ShareData.ins.kind == .retail {
                        appDelegate.callRetailMainVc()
                    }
                    else {
                        appDelegate.calllWsaleMainVc()
                    }
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else {
            appDelegate.callLoginVc()
        }
    }
}
