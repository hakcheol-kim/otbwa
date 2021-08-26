//
//  ModifyMyInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON
class ModifyMyInfoViewController: BaseViewController {
    
    @IBOutlet weak var tfId: CTextField!
    @IBOutlet weak var tfCurrentPw: CTextField!
    @IBOutlet weak var tfNewPw: CTextField!
    @IBOutlet weak var tfNewComfirmPw: CTextField!
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var tfPhone: CTextField!
    @IBOutlet weak var tfAuthCode: CTextField!
    @IBOutlet weak var btnSendSms: CButton!
    @IBOutlet weak var btnAuth: CButton!
    @IBOutlet weak var btnSave: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var data: JSON!
    var isSendSms: Bool = false
    var isCheckAuthCode: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "기본정보 수정", nil)
        safetyView.isHidden = !Utility.isEdgePhone()
        
        self.addTapGestureKeyBoardDown()
        tfCurrentPw.inputAccessoryView = toolBar
        tfNewPw.inputAccessoryView = toolBar
        tfNewComfirmPw.inputAccessoryView = toolBar
        tfPhone.inputAccessoryView = toolBar
        tfAuthCode.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
     
        decorationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    func decorationUI() {
        let name = data["name"].stringValue
        let id = data["id"].stringValue
        let phone = data["phone"].stringValue.getNumberString()
        tfName.text = name
        tfId.text = id
        tfPhone.text = phone
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSendSms {
            guard let phone = tfPhone.text, phone.isEmpty == false else {
                self.showToast("휴대폰 번호를 입력해주세요")
                return
            }
            if phone.validateKorPhoneNumber() == false {
                self.showToast("휴대폰 번호 형식이 아닙니다.")
                return
            }
            let param:[String:Any] = ["phone" : phone, "type" : "find_id"]
            isSendSms = false
            ApiManager.ins.requestSendSmsAuthCode(param) { res in
                let success = res["success"].boolValue
                if success {
                    self.isSendSms = true
                    self.showToast("인증코드가 발송되었습니다.")
                    self.tfAuthCode.becomeFirstResponder()
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnAuth {
            guard let phone = tfPhone.text,  phone.isEmpty == false else {
                self.showToast("휴대폰 번호를 입력해주세요")
                return
            }
            if phone.validateKorPhoneNumber() == false {
                self.showToast("휴대폰 번호 형식이 아닙니다.")
                return
            }
            
            guard let authcode = tfAuthCode.text, authcode.isEmpty == false else {
                self.showToast("인증코드 입력해주세요.")
                return
            }
            if (isSendSms == false) {
                self.showToast("휴대폰 번호를 인증해주세요")
                return
            }
            
            let param:[String:Any] = ["auth_num": authcode, "phone":phone]
            ApiManager.ins.requestCheckAuthCodeFindId(param) { res in
                let success = res["success"].boolValue
                if success {
                    self.view.endEditing(true)
                    self.isCheckAuthCode = true
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnSave {
            guard let curPw = tfCurrentPw.text, curPw.isEmpty == false else {
                self.showToast("현재 비밀번호를 입력해주세요.")
                return
            }
            guard let newPw = tfNewPw.text, newPw.isEmpty == false else {
                self.showToast("새 비밀번호를 입력해주세요.")
                return
            }
            guard let newPwCom = tfNewComfirmPw.text, newPwCom.isEmpty == false else {
                self.showToast("비밀번호를 다시 한번 입력해주세요.")
                return
            }
            guard newPw == newPwCom else {
                self.showToast("비밀번호가 일치하지 않습니다.")
                return
            }
            
            if isCheckAuthCode == false || isSendSms == false {
                self.showToast("전화번호 인증을 완료해주세요.")
                return
            }
            var param = [String:Any]()
            param["id"] = data["id"].stringValue
            param["new_pw"] = newPwCom
            param["phone"] = (tfPhone.text!).getNumberString
            param["pw"] = curPw
            param["user_no"] = ShareData.ins.userNo
            
            ApiManager.ins.requestModifyMyInfo(param) { res in
                if res["success"].boolValue {
                    self.navigationController?.popViewController(animated: true)
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
extension ModifyMyInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  textField == tfCurrentPw {
            tfNewPw.becomeFirstResponder()
        }
        else if textField == tfNewPw {
            tfNewComfirmPw.becomeFirstResponder()
        }
        else if textField == tfNewComfirmPw {
            tfPhone.becomeFirstResponder()
        }
        else if textField == tfAuthCode {
            self.view.endEditing(true)
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text, let txtRange = Range(range, in: string) else {
//            return false
//        }
//        let newTxt = text.replacingCharacters(in: txtRange, with: string)
//        if textField == tfPhone {
//            isSendSms = false
//        }
        return true
    }
}
