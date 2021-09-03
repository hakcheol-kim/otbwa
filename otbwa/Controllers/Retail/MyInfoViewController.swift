//
//  MyInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class MyInfoViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    
    @IBOutlet weak var btnModiMyInfo: UIButton!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbUserPhoneNum: UILabel!
    
    @IBOutlet weak var btnModiStore: UIButton!
    @IBOutlet weak var svCeoName: UIStackView!
    @IBOutlet weak var svStoreName: UIStackView!
    @IBOutlet weak var svPreStoreName: UIStackView!
    @IBOutlet weak var svHastags: UIStackView!
    @IBOutlet weak var svCompNum: UIStackView!
    @IBOutlet weak var svAddress: UIStackView!
    @IBOutlet weak var svTel: UIStackView!
    @IBOutlet weak var btnCompImage: CButton!
    
    @IBOutlet var svBank: UIStackView!
    @IBOutlet var btnModiBank: UIButton!
    @IBOutlet var lbBankName: UILabel!
    @IBOutlet var lbBankNum: UILabel!
    @IBOutlet var lbHolderName: UILabel!
    
    var data:JSON!
    let isWsale = (ShareData.ins.kind.rawValue == "wsale")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUi()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        if ShareData.ins.kind.rawValue == "wsale" {
            CNavigationBar.drawTitle(self, "매장정보 수정", nil)
            lbTitle.textAlignment = .center
            lbSubTitle.textAlignment = .center
        }
        else {
            CNavigationBar.drawTitle(self, "상점 정보", nil)
        }
        svBank.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestMyPageStoreInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func requestMyPageStoreInfo() {
        ApiManager.ins.requestMyPageAndStoreInfo(userNo: ShareData.ins.userNo) { res in
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
    func initUi() {
        lbTitle.text = ""
        lbSubTitle.text = ""
        lbUserName.text = ""
        lbUserPhoneNum.text = ""
        lbBankName.text = ""
        lbBankNum.text = ""
        lbHolderName.text = ""
    }
    func decorationUi() {
        let id = data["id"].stringValue     ///abc005",
        let name = data["name"].stringValue     ///서은결",
        let addr = data["addr"].stringValue     ///서울 금천구 가산동 371-28 우림라이온스밸리 1110",
        let comp_nm_scd = data["comp_nm_scd"].stringValue     ///abc",
        let tel = data["tel"].stringValue     ///02-0608-1614",
        let bank = data["bank"].stringValue     ///",
        let representation = data["representation"].stringValue     ///서은결",
        let hashtag = data["hashtag"].arrayValue     ///ull,
        let holder = data["holder"].stringValue     ///",
        let account = data["account"].stringValue     ///",
        let img = data["img"].stringValue
        let comp_num = data["comp_num"].stringValue     ///123-0608-1614",
        let category_no = data["category_no"].stringValue     ///,
        let phone = data["phone"].stringValue     ///011-4877-2700",
        let comp_nm = data["comp_nm"].stringValue     ///ABCSOME"
        
        lbTitle.text = comp_nm
        lbSubTitle.text = comp_nm_scd
        
        lbUserName.text = name
        lbUserPhoneNum.text = phone
        
        svCeoName.isHidden = true
        svStoreName.isHidden = true
        svPreStoreName.isHidden = true
        svHastags.isHidden = true
        svCompNum.isHidden = true
        svAddress.isHidden = true
        svTel.isHidden = true
        
        
        if isWsale {
            svCeoName.isHidden = true
        }
        else if representation.isEmpty == false, let lbTitle = svCeoName.viewWithTag(101) as? UILabel {
            svCeoName.isHidden = false
            lbTitle.text = representation
        }
        
        if comp_nm.isEmpty == false, let lbTitle = svStoreName.viewWithTag(101) as? UILabel {
            svStoreName.isHidden = false
            lbTitle.text = comp_nm
        }
        if comp_nm_scd.isEmpty == false, let lbTitle = svPreStoreName.viewWithTag(101) as? UILabel {
            svPreStoreName.isHidden = false
            lbTitle.text = comp_nm_scd
        }
        if comp_num.isEmpty == false, let lbTitle = svCompNum.viewWithTag(101) as? UILabel {
            svCompNum.isHidden = false
            lbTitle.text = comp_num
        }
        if addr.isEmpty == false, let lbTitle = svAddress.viewWithTag(101) as? UILabel {
            svAddress.isHidden = false
            lbTitle.text = addr
        }
        if tel.isEmpty == false, let lbTitle = svTel.viewWithTag(101) as? UILabel {
            svTel.isHidden = false
            lbTitle.text = tel
        }
        
        if isWsale == true && hashtag.isEmpty == false, let lbTitle = svHastags.viewWithTag(101) as? UILabel {
            svHastags.isHidden = false
            var title = ""
            for item in hashtag {
                let tmp = item["name"].stringValue
                title.append("\(tmp),")
            }
            title.removeLast()
            lbTitle.text = title
        }
        
        if ShareData.ins.kind.rawValue == "wsale" {
            svBank.isHidden = false
            lbBankName.text = bank
            lbBankNum.text = account
            lbHolderName.text = holder
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnModiMyInfo {
            let vc = ModifyMyInfoViewController.instantiateFromStoryboard(.main)!
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnModiStore {
            let vc = ModifyStoreInfoViewController.instantiateFromStoryboard(.main)!
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnModiBank {
            let vc = ModifyBankInfoViewController.instantiateFromStoryboard(.main)!
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnCompImage {
            let vc = ImageShowViewController.instantiateFromStoryboard(.common)!
            vc.vcTitle = "사업자등록증"
            vc.url = data["img"].stringValue
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
