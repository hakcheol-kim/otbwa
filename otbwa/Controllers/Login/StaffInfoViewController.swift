//
//  StaffInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class StaffInfoViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var btnIdCheck: CButton!
    @IBOutlet weak var btnSms: CButton!
    @IBOutlet weak var btnAuth: CButton!
    
    @IBOutlet weak var tfId: CTextField!
    @IBOutlet weak var tfPw: CTextField!
    @IBOutlet weak var tfPwComfirm: CTextField!
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var tfPhoneNum: CTextField!
    @IBOutlet weak var tfAuth: CTextField!
    
    @IBOutlet weak var btnTermTotal: UIButton!
    @IBOutlet weak var btnTermUsing: UIButton!
    @IBOutlet weak var btnTermPrivacy: UIButton!
    @IBOutlet weak var btnTermSms: UIButton!

    
    let toolBar = CToolbar.init(barItems: [.up, .down, .keyboardDown])
    
    var arrFoucsTf: [CTextField]!
    var tfFocus: CTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "도매 회원가입", nil)
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        
        tfId.inputAccessoryView = toolBar
        tfPw.inputAccessoryView = toolBar
        tfPwComfirm.inputAccessoryView = toolBar
        tfName.inputAccessoryView = toolBar
        tfPhoneNum.inputAccessoryView = toolBar
        tfAuth.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor: #selector(onClickedBtnActions(_:)))
        self.addTapGestureKeyBoardDown()
        safetyView.isHidden = !isEdgePhone
        arrFoucsTf = [tfId, tfPw, tfPwComfirm, tfName, tfPhoneNum, tfAuth]
        
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
        else if sender == btnNext {
            
            let vc = JoinCompletionViewController.instantiateFromStoryboard(.login)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
}

extension StaffInfoViewController: UITextFieldDelegate {
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
    
}
