//
//  WholesaleCeoStoreInofViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/31.
//

import UIKit

class WholesaleCeoStoreInofViewController: BaseViewController {

    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var btnFile: CButton!
    @IBOutlet weak var tfFileName: CTextField!
    @IBOutlet weak var tfCompanyNum: CTextField!
    @IBOutlet weak var tfCompanyPhone: CTextField!
    @IBOutlet weak var tfHashTags: CTextField!
    @IBOutlet weak var btnHashTag: CButton!
    
    @IBOutlet weak var btnTermTotal: UIButton!
    @IBOutlet weak var btnTermUsing: UIButton!
    @IBOutlet weak var btnTermPrivacy: UIButton!
    @IBOutlet weak var btnTermSms: UIButton!
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "도매 회원가입", nil)
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        
        self.addTapGestureKeyBoardDown()
        tfFileName.inputAccessoryView = toolBar
        tfCompanyNum.inputAccessoryView = toolBar
        tfCompanyPhone.inputAccessoryView = toolBar
        tfHashTags.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor:#selector(actionKeybardDown))
        safetyView.isHidden = !isEdgePhone
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnHashTag {
            let vc = HashTagViewController.initWithCompletion { items in
                
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
}
