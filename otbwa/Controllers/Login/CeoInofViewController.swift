//
//  CeoInofViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class CeoInofViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var btnIdCheck: CButton!
    @IBOutlet weak var btnSms: CButton!
    @IBOutlet weak var btnAuth: CButton!
    @IBOutlet weak var tfId: CTextField!
    @IBOutlet weak var tfPw: CTextField!
    @IBOutlet weak var tfPwComfirm: CTextField!
    @IBOutlet weak var tfStoreName: CTextField!
    @IBOutlet weak var tfCeoName: CTextField!
    @IBOutlet weak var tfPhoneNum: CTextField!
    @IBOutlet weak var tfAuth: CTextField!
    @IBOutlet weak var svStoreName: UIStackView!
    
    let toolBar = CToolbar.init(barItems: [.up, .down, .keyboardDown])
    var isCheckedId:Bool = false {
        didSet {
            if isCheckedId {
                btnIdCheck.backgroundColor = RGB(223, 223, 223)
                btnIdCheck.borderColor = RGB(223, 223, 223)
                btnIdCheck.setTitleColor(UIColor.white, for: .normal)
            }
            else {
                btnIdCheck.backgroundColor = UIColor.white
                btnIdCheck.borderColor = UIColor(named: "AccentColor")!
                btnIdCheck.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
            }
        }
    }
    var arrFoucsTf: [CTextField]!
    var tfFocus: CTextField!
    var user: UserInfo!
    var isCheckAuth: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        if user.kind == "wsale" {
            arrFoucsTf = [tfId, tfPw, tfPwComfirm, tfStoreName, tfCeoName, tfPhoneNum, tfAuth]
            CNavigationBar.drawTitle(self, "도매 회원가입", nil)
        }
        else {
            arrFoucsTf = [tfId, tfPw, tfPwComfirm, tfCeoName, tfPhoneNum, tfAuth]
            CNavigationBar.drawTitle(self, "소매 회원가입", nil)
            svStoreName.isHidden = true
        }
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        
        tfId.inputAccessoryView = toolBar
        tfPw.inputAccessoryView = toolBar
        tfPwComfirm.inputAccessoryView = toolBar
        tfStoreName.inputAccessoryView = toolBar
        tfCeoName.inputAccessoryView = toolBar
        tfPhoneNum.inputAccessoryView = toolBar
        tfAuth.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor: #selector(onClickedBtnActions(_:)))
        self.addTapGestureKeyBoardDown()
        safetyView.isHidden = !isEdgePhone
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == TAG_TOOL_KEYBOARD_DOWN {
            self.view.endEditing(true)
        }
        else if sender.tag == TAG_TOOL_BAR_UP {
            if let arrFoucsTf = arrFoucsTf, let tfFocus = self.tfFocus {
                let index:Int = arrFoucsTf.firstIndex { (obj) -> Bool in
                    obj as NSObject == tfFocus as NSObject
                } ?? 0
                
                if index-1 >= 0 {
                    let newFocusObj = arrFoucsTf[index-1]
                    if newFocusObj.becomeFirstResponder() {}
                }
            }
        }
        else if sender.tag == TAG_TOOL_BAR_DOWN {
            if let arrFoucsTf = arrFoucsTf, let tfFocus = self.tfFocus {
                let index:Int = arrFoucsTf.firstIndex { (obj) -> Bool in
                    obj as NSObject == tfFocus as NSObject
                } ?? 0
                
                if index+1 < arrFoucsTf.count {
                    let newFocusObj = arrFoucsTf[index+1]
                    if newFocusObj.becomeFirstResponder() {}
                }
            }
        }
        else if sender == btnIdCheck {
            guard let id = tfId.text, id.isEmpty == false else {
                self.showToast("아이디를 입력해주세요.")
                return
            }
            ApiManager.ins.requestDuplicateCheckId(id) { res in
                let success = res["success"].boolValue
                if success {
                    let dupYN = res["data"]["dupYN"].stringValue
                    if dupYN == "N" {
                        self.showToast("사용해도 되는 아이디입니다")
                        self.isCheckedId = true
                        self.tfPw.becomeFirstResponder()
                    }
                    else {
                        self.showToast("중복된 아이디 입니다")
                    }
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnSms {
            guard let phone = tfPhoneNum.text, phone.isEmpty == false else {
                self.showToast("휴대폰 번호를 입력해주세요")
                return
            }
            if phone.validateKorPhoneNumber() == false {
                self.showToast("휴대폰 번호 형식이 아닙니다.")
                return
            }
            let param:[String:Any] = ["phone" : phone, "type" : "signup"]
            isCheckAuth = false
            ApiManager.ins.requestSendSmsAuthCode(param) { res in
                let success = res["success"].boolValue
                if success {
                    self.showToast("인증코드가 발송되었습니다.")
                    self.tfAuth.becomeFirstResponder()
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnAuth {
            guard let phone = tfPhoneNum.text, phone.isEmpty == false else {
                self.showToast("휴대폰 번호를 입력해주세요")
                return
            }
            if phone.validateKorPhoneNumber() == false {
                self.showToast("휴대폰 번호 형식이 아닙니다.")
                return
            }
            
            guard let authcode = tfAuth.text, authcode.isEmpty == false else {
                self.showToast("인증코드 입력해주세요.")
                return
            }
            isCheckAuth = false
            let param:[String:Any] = ["auth_num": authcode, "phone":phone]
            ApiManager.ins.requestCheckAuthCode(param) { res in
                let success = res["success"].boolValue
                if success {
                    self.view.endEditing(true)
                    self.view.makeToast("인증이 완료되었습니다.")
                    self.isCheckAuth = true
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }

        }
        else if sender == btnNext {
            guard let id = tfId.text, id.isEmpty == false else {
                self.showToast("아이디를 입력해주세요")
                return
            }
            guard let pw = tfPw.text, pw.isEmpty == false else {
                self.showToast("비밀번호를 입력해주세요")
                return
            }
            guard let pw2 = tfPwComfirm.text, pw2.isEmpty == false else {
                self.showToast("비밀번호를 한번 더 입력해주세요")
                return
            }
            if pw != pw2 {
                self.showToast("비밀번호가 일치하지 않습니다.")
                return
            }
            
            if user.kind == "wsale" {
                guard let storeName = tfStoreName.text, storeName.isEmpty == false else {
                    self.showToast("상호명을 입력해주세요")
                    return
                }
                user.comp_nm = storeName
            }
            
            guard let ceoName = tfCeoName.text, ceoName.isEmpty == false else {
                self.showToast("대표자 이름을 입력해주세요")
                return
            }
            guard let phone = tfPhoneNum.text, phone.isEmpty == false else {
                self.showToast("휴대폰 번호를 인증해주세요")
                return
            }
            if isCheckAuth == false {
                self.showToast("휴대폰 번호를 인증해주세요")
                return
            }
            
            user.id = id
            user.pw = pw
            user.name = ceoName
            user.phone = phone
            
            if user.kind == "retail" && user.type == "ceo" {
                let vc = ProductStyleSelectionViewController.instantiateFromStoryboard(.login)!
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = StoreInofViewController.instantiateFromStoryboard(.login)!
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension CeoInofViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            tfFocus = textField
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField is CTextField {
            if let arrFoucsTf = arrFoucsTf {
                let index:Int = arrFoucsTf.firstIndex { (obj) -> Bool in
                    obj as NSObject == textField
                } ?? (arrFoucsTf.count-1)
                
                if index+1 < arrFoucsTf.count {
                    let newFocusObj = arrFoucsTf[index+1]
                    if newFocusObj.becomeFirstResponder() {}
                }
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text,
              let textRange = Range(range, in: text) else {
            return false
        }
        let _ = text.replacingCharacters(in: textRange, with: string)
        if textField == tfId {
            self.isCheckedId = false
        }
        else if textField == tfPhoneNum || textField == tfAuth {
            isCheckAuth = false
        }
        
        return true
    }
}
