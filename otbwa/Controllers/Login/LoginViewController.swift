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
