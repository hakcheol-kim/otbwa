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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbId.isHidden = true
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "아이디 찾기", nil)
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
        else if sender == btnFindPw {
            let vc = FindPwViewController.instantiateFromStoryboard(.login)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if sender == btnSms {
            
        }
        else if sender == btnAuth {
            
        }
    }
    
}

