//
//  UserTypeSelectionViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class UserTypeSelectionViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var svJobType: UIStackView!
    @IBOutlet weak var btnOnline: SelectedButton!
    @IBOutlet weak var btnOffline: SelectedButton!
    @IBOutlet weak var btnCeo: SelectedButton!
    @IBOutlet weak var btnEmp: SelectedButton!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    var joinType: JoinType = .wholesale
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        if joinType == .wholesale {
            CNavigationBar.drawTitle(self, "도매 회원가입", nil)
            svJobType.isHidden = true
        }
        else {
            CNavigationBar.drawTitle(self, "소매 회원가입", nil)
        }
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        
        safetyView.isHidden = !isEdgePhone
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCeo {
            sender.isSelected = true
            btnEmp.isSelected = false
        }
        else if sender == btnEmp {
            sender.isSelected = true
            btnCeo.isSelected = false
        }
        else if sender == btnOffline {
            sender.isSelected = true
            btnOnline.isSelected = false
        }
        else if sender == btnOnline {
            sender.isSelected = true
            btnOffline.isSelected = false
        }
        else if sender == btnNext {
            if joinType == .retail && btnOnline.isSelected == false && btnOffline.isSelected == false {
                self.view.makeToast("업종을 선택해주세요.")
                return
            }
            
            if btnCeo.isSelected == false && btnEmp.isSelected == false  {
                self.view.makeToast("대표 혹은 직원을 선택해주세요.")
                return
            }
            
            if btnCeo.isSelected == true {
                let vc = WholesaleCeoCompanyInfoViewController.instantiateFromStoryboard(.login)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = StaffStoreInfoViewController.instantiateFromStoryboard(.login)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}
