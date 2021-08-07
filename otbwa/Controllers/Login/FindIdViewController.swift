//
//  FindIdViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class FindIdViewController: BaseViewController {
    
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet weak var tfAuthCode: CTextField!
    @IBOutlet weak var btnSms: CButton!
    @IBOutlet weak var btnAuth: CButton!
    @IBOutlet weak var lbId: UILabel!
    @IBOutlet weak var btnLogin: CButton!
    @IBOutlet weak var btnFindPw: CButton!
    
    var isSendSms: Bool = false
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbId.isHidden = true
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "아이디 찾기", nil)
        
        self.addTapGestureKeyBoardDown()
        
        tfPhoneNumber.inputAccessoryView = toolBar
        tfAuthCode.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
     
        if sender == btnLogin {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else if sender == btnFindPw {
            let vc = FindPwViewController.instantiateFromStoryboard(.login)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if sender == btnSms {
            guard let phone = tfPhoneNumber.text, phone.isEmpty == false else {
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
            guard let phone = tfPhoneNumber.text,  phone.isEmpty == false else {
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
                let id = res["data"]["id"].stringValue
                if success && id.isEmpty == false {
                    self.view.endEditing(true)
                    self.lbId.isHidden = false
                    
                    let result = "아이디는 \(id) 입니다."
                    let attr = NSMutableAttributedString.init(string: result, attributes:[.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor : UIColor.white])
                    attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: (result as NSString).range(of: id))
                    self.lbId.attributedText = attr
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


extension FindIdViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in:text) else {
            return false
        }
        
        let _ = text.replacingCharacters(in: textRange, with: string)
        if textField == tfPhoneNumber {
            isSendSms = false
        }
        return true
    }
}
