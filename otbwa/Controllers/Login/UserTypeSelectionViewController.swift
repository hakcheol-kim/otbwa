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
    var user: UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        if user.kind! == "wsale" {
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
            user.type = "ceo"
        }
        else if sender == btnEmp {
            sender.isSelected = true
            btnCeo.isSelected = false
            user.type = "employee"
        }
        else if sender == btnOnline {
            btnOnline.isSelected = true
            btnOffline.isSelected = false
            user.onlineYN = "Y"
        }
        else if sender == btnOffline {
            btnOnline.isSelected = false
            btnOffline.isSelected = true
            user.onlineYN = "N"
        }
        else if sender == btnNext {
            print(user.description)
            if user.kind! == "retail" && btnOnline.isSelected == false && btnOffline.isSelected == false {
                self.view.makeToast("업종을 선택해주세요.")
                return
            }
            
            if btnCeo.isSelected == false && btnEmp.isSelected == false  {
                self.view.makeToast("대표 혹은 직원을 선택해주세요.")
                return
            }
            
            if btnCeo.isSelected == true {
                if user.kind! == "wsale" {
                    let vc = StoreLocationInfoViewController.instantiateFromStoryboard(.login)!
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vc = CeoInfoViewController.instantiateFromStoryboard(.login)!
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                let vc = StaffStoreSelectionViewController.instantiateFromStoryboard(.login)!
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}
