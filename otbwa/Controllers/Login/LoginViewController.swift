//
//  LoginViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class LoginViewController: BaseViewController {
    @IBOutlet weak var tfId: CTextField!
    @IBOutlet weak var tfPw: CTextField!
    @IBOutlet weak var btnAutoLogin: UIButton!
    @IBOutlet weak var btnLogin: CButton!
    @IBOutlet weak var btnJoin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTapGestureKeyBoardDown()
        
        let result = "아직 회원이 아니신가요?  회원가입"
        let sub = "회원가입"
        let attr = NSMutableAttributedString.init(string: result)
        attr.addAttribute(.foregroundColor, value: UIColor(named: "AccentColor")!, range: (result as NSString).range(of: sub))
        btnJoin.setAttributedTitle(attr, for: .normal)
        
        let isAuto = UserDefaults.standard.bool(forKey: Dfskey.autoLogin)
        btnAutoLogin.isSelected = isAuto
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.addKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnJoin {
            let vc = JoinGateWayViewController.instantiateFromStoryboard(.login)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnAutoLogin {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                UserDefaults.standard.setValue(true, forKey: Dfskey.autoLogin)
            }
            else {
                UserDefaults.standard.removeObject(forKey: Dfskey.autoLogin)
            }
            UserDefaults.standard.synchronize()
        }
        else if sender == btnLogin {
            guard let id = tfId.text, id.isEmpty == false else {
                self.showToast("아이디를 입력해주세요.")
                return
            }
            guard let pw = tfPw.text, pw.isEmpty == false else {
                self.showToast("비밀번호를 입력해주세요.")
                return
            }
            self.view.endEditing(true)
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
                    let isAuto = UserDefaults.standard.bool(forKey: Dfskey.autoLogin)
                    if isAuto {
                        UserDefaults.standard.setValue(id, forKey: Dfskey.userId)
                        UserDefaults.standard.setValue(pw, forKey: Dfskey.userPw)
                        UserDefaults.standard.synchronize()
                    }
                    
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
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfId {
            tfPw.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
}
