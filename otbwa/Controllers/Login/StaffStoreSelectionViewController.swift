//
//  WholesaleEmpStoreInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit
import SwiftyJSON

class StaffStoreSelectionViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var btnStoreName: CButton!
    @IBOutlet weak var btnBusinessNum: CButton!
    @IBOutlet weak var tfStoreName: CTextField!
    @IBOutlet weak var tfBusinessNum: CTextField!
    
    var selItem: JSON?
    var user: UserInfo!
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "직원 가입", nil)
        
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        
        
        btnNext.setBackgroundImage(UIImage.color(from: RGB(203, 203, 203)), for: .disabled)
        btnNext.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .normal)
//        btnNext.isEnabled = false
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnStoreName {
            let vc = StoreSelectionViewController.initWithType("name", user.kind!) { item in
                guard let item = item else {
                    return
                }
                self.selItem = item
                self.tfStoreName.text = self.selItem!["comp_nm"].stringValue
                self.tfBusinessNum.text = ""
                self.btnNext.isEnabled = true
            }
            appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
        }
        else if sender == btnBusinessNum {
            let vc = StoreSelectionViewController.initWithType("num", user.kind!) { item in
                guard let item = item else {
                    return
                }
                self.selItem = item
                self.tfStoreName.text = ""
                self.tfBusinessNum.text = self.selItem!["comp_nm"].stringValue
                self.btnNext.isEnabled = true
            }
            appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
        }
        else if sender == btnNext {
            guard let selItem = selItem else {
                self.showToast("상호명을 선택해주세요.")
                return
            }
            user.comp_nm = selItem["comp_nm"].stringValue
            user.comp_num = selItem["comp_num"].stringValue
            user.tel = selItem["comp_tel"].stringValue
            
            let vc = StaffInfoViewController.instantiateFromStoryboard(.login)!
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
