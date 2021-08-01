//
//  JoinGateWayViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class JoinGateWayViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var btnWholesale: SelectedButton!
    @IBOutlet weak var btnRetail: SelectedButton!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "회원가입", nil)
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        safetyView.isHidden = !isEdgePhone
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnWholesale {
            sender.isSelected = true
            btnRetail.isSelected = false
        }
        else if sender == btnRetail {
            sender.isSelected = true
            btnWholesale.isSelected = false
        }
        else if sender == btnNext {
            if btnWholesale.isSelected == false && btnRetail.isSelected == false  {
                self.view.makeToast("도매회원 혹은 소매회원을 선택해주세요.")
                return
            }
            if btnWholesale.isSelected {
                let vc = UserTypeSelectionViewController.instantiateFromStoryboard(.login)!
                vc.joinType = .wholesale
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = UserTypeSelectionViewController.instantiateFromStoryboard(.login)!
                vc.joinType = .retail
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}
