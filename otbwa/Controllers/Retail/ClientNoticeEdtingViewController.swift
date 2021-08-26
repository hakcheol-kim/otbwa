//
//  ClientNoticeEdtingViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/19.
//

import UIKit

class ClientNoticeEdtingViewController: BaseViewController {

    @IBOutlet weak var tfTitle: CTextField!
    @IBOutlet weak var tvContent: CTextView!
    
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var btnCancel: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    @IBAction func onClickBtnActions(_ sender: UIButton) {
        
    }
    
}
