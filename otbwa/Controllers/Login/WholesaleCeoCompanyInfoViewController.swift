//
//  WholesaleCeoCompanyInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit
import SwiftyJSON
class WholesaleCeoCompanyInfoViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var btnBuilding: CButton!
    @IBOutlet weak var btnFlow: CButton!
    @IBOutlet weak var btnRoom: CButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "도매 회원가입", nil)
        
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)

        safetyView.isHidden = !isEdgePhone
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if (sender == btnBuilding) {
            let data = [JSON]()
            let vc = BuildingSelectedViewController.initWithData(data) { item in
                guard let item = item as? JSON else {
                    return
                }
                
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if (sender == btnFlow) {
            let data = [JSON]()
            let vc = FlowSelectedViewController.initWithData(data) { item in
                guard let item = item as? JSON else {
                    return
                }
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if (sender == btnRoom) {
            let vc = RoomSelectedViewController.initWithCompletion(completion: { item in
                guard let item = item as? JSON else {
                    return
                }
                
            })
            self.present(vc, animated: true, completion: nil)
        }
        else if sender == btnNext {
            
            let vc = WholesaleCeoInofViewController.instantiateFromStoryboard(.login)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
