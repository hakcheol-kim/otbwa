//
//  FilterViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit
import SwiftyJSON

class FilterViewController: BaseViewController {
    
    @IBOutlet var arrMenu: [UIButton]!
    @IBOutlet weak var contentView: UIView!
    
    var ftCategoryVc: FtCategoryViewController?
    var ftStyleVc: FtStyleViewController?
    var ftColorVc: FtColorViewController?
    var ftAddressVc: FtAddrViewController?
    var ftAmountVc: FtAmountViewController?
    var ftCountryVc: FtCountyViewController?
    
    var selIndex = 0
    var filters:JSON!
    var completion:((_ item:Any) ->Void)?
    var selViewCtrl: UIViewController? = nil
    
    private var selCategorys: JSON? = nil {
        didSet {
            self.updateUi()
        }
    }
    private var selStyle: JSON? = nil {
        didSet {
            self.updateUi()
        }
    }
    private var selColors: [JSON]? = nil {
        didSet {
            self.updateUi()
        }
    }
    private var selAmount: JSON? = nil {
        didSet {
            self.updateUi()
        }
    }
    private var selCountry: JSON? = nil {
        didSet {
            self.updateUi()
        }
    }
    private var selAddress: JSON? = nil {
        didSet {
            self.updateUi()
        }
    }
    static func initWithSelIndex(_ selIdex:Int, completion:((_ item: Any) ->Void)?) -> FilterViewController {
        let vc = FilterViewController.instantiateFromStoryboard(.common)!
        vc.completion = completion
        vc.selIndex = selIdex
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrMenu = arrMenu.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "필터 설정")
        
        for btn in arrMenu {
            btn.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
        }
        
        self.requestFilerList()
        
        for btn in arrMenu {
            let title = btn.titleLabel?.text
            let attrNor = NSAttributedString.init(string: title!, attributes: [.foregroundColor: UIColor.label, .font:UIFont.systemFont(ofSize: 14, weight: .regular)])

            let attrSel = NSAttributedString.init(string: title!, attributes: [.foregroundColor: UIColor(named: "AccentColor")!, .font:UIFont.systemFont(ofSize: 14, weight: .bold)])
            btn.setAttributedTitle(attrNor, for: .normal)
            btn.setAttributedTitle(attrSel, for: .selected)
            btn.layer.cornerRadius = 6
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.completion?(self.getSelFilters())
    }
    func requestFilerList() {
        ApiManager.ins.requestFilterList { res in
            let succes = res["success"].boolValue
            if (succes) {
                self.filters = res["data"]
                self.configurationMenu()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    func configurationMenu() {
        let tag = 100 + selIndex
        var selBtn: UIButton?
        for btn in arrMenu {
            btn.isSelected = false
            btn.layer.borderColor = UIColor.clear.cgColor
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 6
            
            if btn.tag == tag {
                selBtn = btn
            }
        }
     
        if let selBtn = selBtn {
            selBtn.sendActions(for: .touchUpInside)
        }
    }
    
    func reloadUi() {
        
        if let selViewCtrl = selViewCtrl {
            self.myRemoveChildViewController(childViewController: selViewCtrl)
        }
        if selIndex == 0 {
            let category = filters["category"].arrayValue
            guard category.isEmpty == false else {
                return
            }
            self.ftCategoryVc = FtCategoryViewController.initWithData(category, nil) { (selData, action) in
                if let selData = selData as? JSON {
                    print(selData)
                }
                
                if action == 1 {    //저장
                    self.selCategorys = selData as? JSON
                    self.popViewControllerWithCompletion()
                }
                else if action == 2 {   //초기화
                    self.selCategorys = nil
//                    self.completion?(self.getSelFilters())
                }
                else if action == 3 { //셀 선택
                    if let selData = selData as? JSON, let selCategorys = self.selCategorys, selCategorys["ctgr_id"].stringValue == selData["ctgr_id"].stringValue {
                        self.selCategorys = nil
                    }
                    else {
                        self.selCategorys = selData as? JSON
                    }
                }
            }
            self.myAddChildViewController(superView: contentView, childViewController: ftCategoryVc!)
            self.selViewCtrl = ftCategoryVc
        }
        else if selIndex == 1 {
            let style = filters["style"].arrayValue
            let code = "8010"
            let data = style.filter { item ->Bool in
                return item["level"].intValue == 2 && (item["code"].stringValue.hasPrefix(code) == true)
            }
            self.ftStyleVc = FtStyleViewController.initWithData(data, nil) { (selData, action) in
                if let selData = selData as? JSON {
                    print(selData)
                }
                if action == 1 {    //저장
                    self.selStyle = selData as? JSON
                    self.popViewControllerWithCompletion()
                }
                else if action == 2 {   //초기화
                    self.selStyle = nil
//                    self.completion?(self.getSelFilters())
                }
                else if action == 3 { //셀 선택
                    if let selData = selData as? JSON, let selStyle = self.selStyle, selStyle["code"].stringValue == selData["code"].stringValue {
                        self.selStyle = nil
                    }
                    else {
                        self.selStyle = selData as? JSON
                    }
                }
            }
            self.myAddChildViewController(superView: contentView, childViewController: ftStyleVc!)
            self.selViewCtrl = ftStyleVc
        }
        else if selIndex == 2 {
            let color = filters["color"].arrayValue
            
            self.ftColorVc = FtColorViewController.initWithData(color, nil) { (selData, action) in
                if let selData = selData as? [JSON] {
                    print(selData)
                }
                if action == 1 {    //저장
                    self.selColors = selData as? [JSON]
                    self.popViewControllerWithCompletion()
                }
                else if action == 2 {   //초기화
                    self.selColors = nil
//                    self.completion?(self.getSelFilters())
                }
                else if action == 3 { //셀 선택
                    self.selColors = selData as? [JSON]
                }
                
            }
            self.myAddChildViewController(superView: contentView, childViewController: ftColorVc!)
            self.selViewCtrl = ftColorVc
        }
        else if selIndex == 3 {
            let data:[JSON] = [JSON(["title": "1만원 이하", "min": 0, "max": 10000, "code" : 1]),
                               JSON(["title": "1만원~2만원", "min": 10000, "max": 20000, "code" : 2]),
                               JSON(["title": "2만원~3만원", "min": 20000, "max": 30000, "code" : 3]),
                               JSON(["title": "3만원 이상", "min": 30000, "max": UINT64_MAX, "code" : 4])]
                               
            self.ftAmountVc = FtAmountViewController.initWithData(data, nil) { (selData, action) in
                if let selData = selData as? JSON {
                    print(selData)
                }
                if action == 1 {    //저장
                    self.selAmount = selData as? JSON
                    self.popViewControllerWithCompletion()
                }
                else if action == 2 {   //초기화
                    self.selAmount = nil
//                    self.completion?(self.getSelFilters())
                }
                else if action == 3 { //셀 선택
                    if let selData = selData as? JSON, let selAmount = self.selAmount, selAmount["code"].intValue == selData["code"].intValue {
                        self.selAmount = nil
                    }
                    else {
                        self.selAmount = selData as? JSON
                    }
                }
            }
            self.myAddChildViewController(superView: contentView, childViewController: ftAmountVc!)
            self.selViewCtrl = ftAmountVc
        }
        else if selIndex == 4 {
            let building = filters["building"].arrayValue
            
            self.ftAddressVc = FtAddrViewController.initWithData(building, nil, completion: { (selData, action) in
                if let selData = selData as? JSON {
                    print(selData)
                }
                if action == 1 {    //저장
                    self.selAddress = selData as? JSON
                    self.popViewControllerWithCompletion()
                }
                else if action == 2 {   //초기화
                    self.selAddress = nil
//                    self.completion?(self.getSelFilters())
                }
                else if action == 3 { //셀 선택
                    if let selData = selData as? JSON, let selAddress = self.selAddress, selAddress["ctgr_id"].stringValue == selData["ctgr_id"].stringValue {
                        self.selAddress = nil
                    }
                    else {
                        self.selAddress = selData as? JSON
                    }
                }
            })
            self.myAddChildViewController(superView: contentView, childViewController: ftAddressVc!)
            self.selViewCtrl = ftAddressVc
            
        }
        else if selIndex == 5 {
            let data:[JSON] = [JSON(["value": "대한민국", "code" : "KR"]),
                               JSON(["value": "중국", "code" : "CH"]),
                               JSON(["value": "기타", "code" : "ETC"])]
         
            self.ftCountryVc = FtCountyViewController.initWithData(data, nil) { (selData, action) in
                if let selData = selData as? JSON {
                    print(selData)
                }
                if action == 1 {    //저장
                    self.selCountry = selData as? JSON
                    self.popViewControllerWithCompletion()
                }
                else if action == 2 {   //초기화
                    self.selCountry = nil
//                    self.completion?(self.getSelFilters())
                }
                else if action == 3 { //셀 선택
                    if let selData = selData as? JSON, let selStyle = self.selCountry, selStyle["code"].stringValue == selData["code"].stringValue {
                        self.selCountry = nil
                    }
                    else {
                        self.selCountry = selData as? JSON
                    }
                }
            }
            self.myAddChildViewController(superView: contentView, childViewController: ftCountryVc!)
            self.selViewCtrl = ftCountryVc
        }
        
    }
    func getSelFilters() ->JSON {
        var filters = JSON()
        if let selCategorys = selCategorys, selCategorys.isEmpty == false {
            filters["ft_category"] = selCategorys
        }
        if let selAddress = selAddress, selAddress.isEmpty == false {
            filters["ft_addr"] = selAddress
        }
        if let selColors = selColors, selColors.isEmpty == false {
            filters["ft_color"] = JSON(selColors)
        }
        if let selStyle = selStyle, selStyle.isEmpty == false {
            filters["ft_style"] = selStyle
        }
        if let selAmount = selAmount, selAmount.isEmpty == false {
            filters["ft_amount"] = selAmount
        }
        if let selCountry = selCountry, selCountry.isEmpty == false {
            filters["ft_country"] = selCountry
        }
        return filters
    }
    func popViewControllerWithCompletion() {
        self.navigationController?.popViewController(animated: true)
    }
    func updateUi() {
        let btnMeue = arrMenu[selIndex]
        var hasData: Bool = false
        switch selIndex {
            case 0:
                hasData = (selCategorys != nil)
                break
            case 1:
                hasData = (selStyle != nil)
                break
            case 2:
                hasData = (selColors?.isEmpty == false)
                break
            case 3:
                hasData = (selAmount?.isEmpty == false)
                break
            case 4:
                hasData = (selAddress?.isEmpty == false)
                break
            case 5:
                hasData = (selCountry?.isEmpty == false)
                break
            default:
                break
        }
        
        if hasData {
            hasData = true
            btnMeue.setImage(UIImage(named: "path_2"), for: .normal)
            btnMeue.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
            btnMeue.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 18)
        }
        else {
            btnMeue.setImage(nil, for: .normal)
            btnMeue.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            btnMeue.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag >= 100 {
            self.selIndex = sender.tag - 100
            self.reloadUi()
            
            for btn in arrMenu {
                btn.isSelected = false
                btn.layer.borderColor = UIColor.clear.cgColor
                btn.layer.borderWidth = 1
                btn.layer.cornerRadius = 6
            }
            
            sender.isSelected = true
            sender.layer.borderColor = UIColor(named: "AccentColor")!.cgColor
        }
    }
}
