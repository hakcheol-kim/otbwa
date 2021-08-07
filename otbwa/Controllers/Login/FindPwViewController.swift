//
//  FindPwViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class FindPwViewController: BaseViewController {
    @IBOutlet weak var tfUserId: CTextField!
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet weak var tfAuthCode: CTextField!
    @IBOutlet weak var btnSms: CButton!
    @IBOutlet weak var btnAuth: CButton!
    @IBOutlet weak var svPw: UIStackView!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var btnLogin: CButton!
    @IBOutlet weak var btnFindId: CButton!
    @IBOutlet weak var btnClipPw: CButton!
    
    var isSendSms: Bool = false
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var pw: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "비밀번호 찾기", nil)
        self.addTapGestureKeyBoardDown()
        
        tfUserId.inputAccessoryView = toolBar
        tfPhoneNumber.inputAccessoryView = toolBar
        tfAuthCode.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        
        svPw.isHidden = true
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
        else if sender == btnFindId {
            let vc = FindIdViewController.instantiateFromStoryboard(.login)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if sender == btnSms {
            guard let id = tfUserId.text, id.isEmpty == false else {
                self.showToast("아이디를 입력해주세요")
                return
            }
            guard let phone = tfPhoneNumber.text, phone.isEmpty == false else {
                self.showToast("휴대폰 번호를 입력해주세요")
                return
            }
            if phone.validateKorPhoneNumber() == false {
                self.showToast("휴대폰 번호 형식이 아닙니다.")
                return
            }
            let param:[String:Any] = ["id" : id, "phone" : phone]
            isSendSms = false
            ApiManager.ins.requestSendSmsAuthCodeFindPw(param) { res in
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
            guard let id = tfUserId.text, id.isEmpty == false else {
                self.showToast("아이디를 입력해주세요")
                return
            }
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
            
            let param:[String:Any] = ["id" : id, "auth_num": authcode, "phone":phone]
            ApiManager.ins.requestCheckAuthCodeFindPw(param) { res in
                let success = res["success"].boolValue
                let pw = res["data"]["pw"].stringValue
                if success && pw.isEmpty == false {
                    self.view.endEditing(true)
                    self.svPw.isHidden = false
                    self.pw = pw
                    let result = "임시 비밀번호는 \(pw) 입니다."
                    let attr = NSMutableAttributedString.init(string: result, attributes:[.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor : UIColor.white])
                    attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: (result as NSString).range(of: id))
                    self.lbPassword.attributedText = attr
                    self.btnClipPw.borderColor = UIColor.white
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnClipPw {
            guard let pw = pw, pw.isEmpty == false else {
                self.view.makeToast("임시 비밀번호 없습니다.")
                return
            }
            self.showToast("복사되었습니다.")
            pw.toClipboard()
        }
    }
}

extension FindPwViewController: UITextFieldDelegate {
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
