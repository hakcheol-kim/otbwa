//
//  NotificationViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/31.
//

import UIKit

class NotificationViewController: BaseViewController {
    @IBOutlet weak var btnPush: UIButton!
    @IBOutlet weak var btnDisturb: UIButton!
    @IBOutlet weak var btnSetting: CButton!
    @IBOutlet weak var tfStart: CTextField!
    @IBOutlet weak var tfEnd: CTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "알림/방해금지모드 설정")
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPush {
            
        }
        else if sender == btnDisturb {
            
        }
        else if sender == btnSetting {
            
        }
    }
}
extension NotificationViewController: UITextFieldDelegate {
    
}

