//
//  WMyPageViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class WMyPageViewController: BaseViewController {
    @IBOutlet weak var ivthumb: UIImageView!
    @IBOutlet weak var lbCompNm: UILabel!
    @IBOutlet weak var lbAddr: UILabel!
    @IBOutlet weak var btnTel: UIButton!
    @IBOutlet weak var btnModify: UIButton!
    @IBOutlet weak var svTags: UIStackView!
    @IBOutlet weak var btnSetting: CButton!
 
    @IBOutlet var arrMenu: [CButton]!
    var data:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawTitle(self, UIImage(named: "logo_top"))
        CNavigationBar.drawRight(self, UIImage(named: "ico_close"), nil, 101010, #selector(onClickedBtnActions(_:)))
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        arrMenu = arrMenu.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        arrMenu.forEach { btn in
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        
        btnModify.layer.cornerRadius = 15
        btnModify.layer.maskedCorners = CACornerMask(TL: true, TR: false, BL: true, BR: false)
        
        btnSetting.titleLabel?.numberOfLines = 0
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMyInfo()
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
        let comp_img = data["comp_img"].stringValue
        if comp_img.isEmpty == false {
            ivthumb.setImageCache(comp_img)
        }
        lbAddr.text = data["address"].stringValue
        lbCompNm.text = data["comp_nm"].stringValue
        btnTel.setTitle(data["comp_tel"].stringValue, for: .normal)
        
        for subView in svTags.subviews {
            subView.removeFromSuperview()
        }
        
        let arrTag = data["hashtag"].arrayValue
        for tag in arrTag {
            let name = tag["name"].stringValue
            let btnTag = UIButton.init(type: .custom)
            svTags.addArrangedSubview(btnTag)
            
            btnTag.setTitle("#\(name)", for: .normal)
            btnTag.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            btnTag.backgroundColor = RGB(241, 241, 241)
            btnTag.layer.cornerRadius = 11
            btnTag.translatesAutoresizingMaskIntoConstraints = false
            btnTag.heightAnchor.constraint(equalToConstant: 22).isActive = true
            btnTag.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            btnTag.setTitleColor(RGB(136 , 136, 136), for: .normal)
            btnTag.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == 101010 {
            self.transitionPop(duration: 0.25, type: .fromRight)
        }
        else if sender == btnSetting {
            let vc = ImageSelectOptionViewController.initWithCompletion { vcs, soureType in
                vcs?.dismiss(animated: true, completion: nil)
                self.showImagePicker(soureType)
            }
            appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
        else if sender == btnModify {
            let vc = MyInfoViewController.instantiateFromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnTel {
            let tel = data["comp_tel"].stringValue
            guard tel.isEmpty == false  else {
                return
            }
            appDelegate.openUrl("tel:\(tel)", completion: nil)
        }
        else if let btn = sender as? CButton, arrMenu.contains(btn) == true {
            if sender.tag == 0 {
                let vc = EmployeeManagementViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 1 {
                let vc = AdminNoticeListViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 2 {
                let vc = NotificationViewController.instantiateFromStoryboard(.wsale)!
                vc.passData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 3 { //고객센터
                let vc = ContatUsViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 4 {
                let vc = TermsTabViewController.init()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if sender.tag == 5 { //로그아웃
                UserDefaults.standard.removeObject(forKey: Dfskey.userId)
                UserDefaults.standard.removeObject(forKey: Dfskey.userPw)
                appDelegate.callLoginVc()
            }
        }
    }
    func showImagePicker(_ sourceType:UIImagePickerController.SourceType) {
        let vc = CImagePickerController.initWithSouretType(sourceType, false, 1) { data in
            if let data = data as? UIImage {
                self.ivthumb.image = data
                self.requestModifyCompInfo(data)
            }
            else if let imgs = data as? [UIImage], let img = imgs.first {
                self.ivthumb.image = img
                self.requestModifyCompInfo(img)
            }
        }
        appDelegate.window?.rootViewController?.present(vc, animated: true)
    }
    func requestModifyCompInfo(_ img:UIImage) {
        var param = [String:Any]()
        param["comp_no"] = ShareData.ins.compNo
        param["comp_img"] = img
        param["user_no"] = ShareData.ins.userNo
        
        ApiManager.ins.rquestRegistCompImg(param) { res in
            if res["success"].boolValue {
                
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
}


