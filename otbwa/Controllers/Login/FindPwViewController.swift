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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "비밀번호 찾기", nil)
        self.addTapGestureKeyBoardDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
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
            
        }
        else if sender == btnAuth {
            
        }
    }
    
}

