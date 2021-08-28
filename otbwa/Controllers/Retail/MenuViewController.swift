//
//  MenuViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class MenuViewController: BaseViewController {
    @IBOutlet weak var btnMyProduct: UIButton!
    @IBOutlet weak var lbCompName: UILabel!
    @IBOutlet weak var lbUserId: UILabel!
    @IBOutlet weak var ivCompImg: UIImageView!
   
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnRecent: UIButton!
    @IBOutlet weak var btnNotice: UIButton!
    
    @IBOutlet var arrMenu: [CButton]!
    var data:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawTitle(self, UIImage(named: "logo_top"))
        CNavigationBar.drawRight(self, UIImage(named: "ico_close"), nil, 101010, #selector(onClickedBtnActions(_:)))
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        ivCompImg.layer.cornerRadius = ivCompImg.bounds.size.height/2
        btnMyProduct.layer.cornerRadius = btnMyProduct.bounds.size.height/2
        btnMyProduct.layer.maskedCorners = CACornerMask(TL: true, TR: false, BL: true, BR: false)
        let title = "내 상점정보 보기 ⟩"
        btnMyProduct.setTitle(title, for: .normal)
        
        arrMenu = arrMenu.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        arrMenu.forEach { btn in
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        
        requestMyInfo()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func requestMyInfo() {
        ApiManager.ins.requestMyPageInfo(param: ["user_no":ShareData.ins.userNo]) { res in
            let success = res["success"].boolValue
            if success {
                self.data = res["data"]
                self.decorationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
    func decorationUi() {
        lbCompName.text = self.data["comp_nm"].stringValue
        lbUserId.isHidden = true
        let comp_img = data["comp_img"].stringValue
        
        ivCompImg.isHidden = true
        if comp_img.isEmpty == false {
            ivCompImg.isHidden = false
            ivCompImg.setImageCache(comp_img)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == 101010 {
            self.transitionPop(duration: 0.25, type: .fromRight)
        }
        else if sender == btnMyProduct {
            let vc = MyInfoViewController.instantiateFromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnLike {
            let vc = ProductHistoryMenuViewController.instantiateFromStoryboard(.main)!
            vc.selectedIndex = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnRecent {
            let vc = ProductHistoryMenuViewController.instantiateFromStoryboard(.main)!
            vc.selectedIndex = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnNotice {
            let vc = ProductHistoryMenuViewController.instantiateFromStoryboard(.main)!
            vc.selectedIndex = 2
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if let btn = sender as? CButton, arrMenu.contains(btn) == true {
            if sender.tag == 0 {
                let vc = ProductOrderManagerViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 1 {
                let vc = ClientMangerTabViewController.init()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 2 {
                let vc = EmployeeManagementViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 3 {
                CAlertViewController.show(type: .alert, message: "옷봐 App 다운로드 주소가\n복사되었습니다.\nSNS, 카카오톡을 통해 옷봐를\n알려주세요.", actions: [.ok]) { (vcs, action) in
                    vcs.dismiss(animated: true, completion: nil)
                    if action == 0 {
                        
                    }
                }
            }
            else if sender.tag == 4 {
                let vc = AdminNoticeListViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 5 { //고객센터
                let vc = ContatUsViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 6 {   // 이용약관
                let vc = TermsTabViewController.init()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 7 { //로그아웃
                UserDefaults.standard.removeObject(forKey: Dfskey.userId)
                UserDefaults.standard.removeObject(forKey: Dfskey.userPw)
                appDelegate.callLoginVc()
            }
        }
    }
}

