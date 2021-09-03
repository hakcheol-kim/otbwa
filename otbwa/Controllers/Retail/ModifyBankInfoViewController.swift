//
//  ModifyBankInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/09/03.
//

import UIKit
import SwiftyJSON
class ModifyBankInfoViewController: BaseViewController {
    
    @IBOutlet weak var tfBank: CTextField!
    @IBOutlet weak var tfAccountNum: CTextField!
    @IBOutlet weak var tfHolderName: CTextField!
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    var data:JSON!
    let toolbar = CToolbar.init(barItems: [.keyboardDown])
    
    override func viewDidLoad() {
        safetyView.isHidden = !isEdgePhone
        
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "계좌정보 수정")
        
        tfBank.inputAccessoryView = toolbar
        tfAccountNum.inputAccessoryView = toolbar
        tfHolderName.inputAccessoryView = toolbar
        toolbar.addTarget(self, selctor: #selector(actionKeybardDown))
        configurationUi()
    }
    func configurationUi() {
        let account = data["account"].stringValue
        let bank = data["bank"].stringValue
        let holder = data["holder"].stringValue
        tfBank.text = bank
        tfAccountNum.text = account
        tfHolderName.text = holder
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnOk {
            guard let bankName = tfBank.text, bankName.isEmpty == false else {
                self.showToast("은행명을 입력해주세요.")
                return
            }
            guard let accountNum = tfAccountNum.text, accountNum.isEmpty == false else {
                self.showToast("계좌번호를 입력해주세요.")
                return
            }
            guard let holderName = tfHolderName.text, holderName.isEmpty == false else {
                self.showToast("예금주를 입력해주세요.")
                return
            }
            
            var param = [String:Any]()
            param["comp_no"] = ShareData.ins.compNo
            param["user_no"] = ShareData.ins.userNo
            param["account"] = bankName
            param["bank"] = accountNum
            param["holder"] = holderName
            
            ApiManager.ins.requestModifyBankAccount(param) { res in
                if res["success"].boolValue {
                    appDelegate.window?.makeToast("계좌 정보가 수정되었습니니다.")
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

extension ModifyBankInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfBank {
            tfAccountNum.becomeFirstResponder()
        }
        else if textField == tfAccountNum {
            tfHolderName.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
}
