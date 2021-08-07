//
//  WholesaleCeoCompanyInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit
import SwiftyJSON
class StoreLocationInfoViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var btnBuilding: CButton!
    @IBOutlet weak var btnFlow: CButton!
    @IBOutlet weak var btnRoom: CButton!
    var user: UserInfo!
    var filters: JSON!
    var selBuilding: JSON?
    var selFloor: JSON?
    var selRoom: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "도매 회원가입", nil)
        
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)

        safetyView.isHidden = !isEdgePhone
        
        requestFilterList()
    }
    
    func requestFilterList() {
        ApiManager.ins.requestFilterList { res in
            let code = res["code"].intValue
            let data = res["data"]
            if code == 0, data.isEmpty == false {
                self.filters = data
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if (sender == btnBuilding) {
            let building = filters["building"].arrayValue
            let vc = BuildingSelectedViewController.initWithData(building) { item in
                guard let item = item as? JSON else {
                    return
                }
                self.selBuilding = item
                if let lbTitle = self.btnBuilding.viewWithTag(100) as? UILabel {
                    lbTitle.text = self.selBuilding!["name"].stringValue
                    lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .regular)
                    lbTitle.textColor = UIColor(named: "AccentColor")
                }
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if (sender == btnFlow) {
            guard let selBuilding = selBuilding, selBuilding.isEmpty == false else {
                self.view.makeToast("건물을 선택해주세요.")
                return
            }
            let building = filters["building"].arrayValue
            let floors = building.filter { item in
                return (item["up_ctgr_id"].stringValue == selBuilding["ctgr_id"].stringValue)
            }
            let vc = FlowSelectedViewController.initWithData(floors) { item in
                guard let item = item as? JSON else {
                    return
                }
                self.selFloor = item
                if let lbTitle = self.btnFlow.viewWithTag(100) as? UILabel {
                    lbTitle.text = self.selFloor!["name"].stringValue
                    lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .regular)
                    lbTitle.textColor = UIColor(named: "AccentColor")
                }
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if (sender == btnRoom) {
            guard let selFloor = selFloor, selFloor.isEmpty == false else {
                self.view.makeToast("건물을 선택해주세요.")
                return
            }
            let vc = RoomSelectedViewController.initWithCompletion(selFloor, completion: { item in
                guard let item = item as? JSON else {
                    return
                }
                self.selRoom = item
                if let lbTitle = self.btnRoom.viewWithTag(100) as? UILabel {
                    lbTitle.text = self.selRoom!["name"].stringValue
                    lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .regular)
                    lbTitle.textColor = UIColor(named: "AccentColor")
                }
            })
            self.present(vc, animated: true, completion: nil)
        }
        else if sender == btnNext {
            
            guard let _ = selBuilding else {
                self.view.makeToast("주소를 빠짐없이 선택해주세요.")
                return
            }
            guard let _ = selFloor else {
                self.view.makeToast("건물을 선택해주세요.")
                return
            }
            
            if let selRoom = selRoom {
                user.building = selRoom["ctgr_id"].stringValue
            }
            else {
                user.building = selFloor!["ctgr_id"].stringValue
            }
            let vc = CeoInofViewController.instantiateFromStoryboard(.login)!
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
