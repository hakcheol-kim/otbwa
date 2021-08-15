//
//  FilterSectionView.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/31.
//

import UIKit
import SwiftyJSON
class FilterGropView: UIView {
    @IBOutlet weak var btnGroupTitle: CButton!
    @IBOutlet weak var svList: UIStackView!
    
    var type: FitlerViewType = .hasTag
    var listData:[JSON]?
    var completion:((_ data:Any, _ isSelected:Bool)->Void)?
    var display: JSON!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ display:JSON, _ listData:[JSON]?, _ type:FitlerViewType) {
        self.listData = listData
        self.type = type
        self.display = display
        
        guard let listData = listData, listData.isEmpty == false else {
            return
        }
        btnGroupTitle.data = display
        
        let title = display["name"].stringValue
        btnGroupTitle.setTitle(title, for: .normal)
        
        if type == .address {
            let attrNor = NSAttributedString.init(string: title, attributes: [.foregroundColor: UIColor.white, .font:UIFont.systemFont(ofSize: 12, weight: .regular)])
            let attrSel = NSAttributedString.init(string: title, attributes: [.foregroundColor: UIColor(named: "AccentColor")!, .font:UIFont.systemFont(ofSize: 12, weight: .regular)])
            
            btnGroupTitle.setAttributedTitle(attrNor, for: .normal)
            btnGroupTitle.setAttributedTitle(attrSel, for: .selected)
        }
        
        let level3 = listData.filter { (item) -> Bool in
            return display["ctgr_id"].stringValue == item["up_ctgr_id"].stringValue
        }
        
        for item in level3 {
            let btn = CButton.init()
            btn.contentHorizontalAlignment = .left
            let title = item["name"].stringValue
            let attrNor = NSAttributedString.init(string: title, attributes: [.font : UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor : UIColor.label])
            btn.setAttributedTitle(attrNor, for: .normal)
            let attrSel = NSAttributedString.init(string: title, attributes: [.font : UIFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor : UIColor(named: "AccentColor")!])
            btn.setAttributedTitle(attrSel, for: .selected)
            svList.addArrangedSubview(btn)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
            
            btn.data = item
        }
        svList.isHidden = true
    }
    
    func reloadUi() {
        if self.type == .address {
            for subview in svList.subviews {
                if let btn = subview as? CButton, let data = btn.data as? JSON, let selData = ShareData.ins.selectedFilterList.last {
                    if data["ctgr_id"].stringValue == selData["ctgr_id"].stringValue {
                        btn.isSelected = true
                    }
                    else {
                        btn.isSelected = false
                    }
                }
            }
            
            if let data = btnGroupTitle.data as? JSON, let selData = ShareData.ins.selectedFilterList.last {
                if data["ctgr_id"].stringValue == selData["ctgr_id"].stringValue {
                    btnGroupTitle.isSelected = true
                }
                else {
                    btnGroupTitle.isSelected = false
                }
            }
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnGroupTitle {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                svList.isHidden = false
            }
            else {
                svList.isHidden = true
            }
            
            guard let data = btnGroupTitle.data else {
                return
            }
            self.completion?(data, sender.isSelected)
        }
        else if let sender = sender as? CButton {
            guard var data = sender.data as? JSON else {
                return
            }
            if (sender.isSelected == false) {
                if  self.type == .hasTag && ShareData.ins.selectedFilterList.count >= 3 {
                    appDelegate.window!.makeToast("해시태그는 최대 3개까지 선택할 수 있습니다.")
                    return
                }
                else if self.type == .address {
                    for btn in svList.subviews {
                        if let btn = btn as? CButton {
                            btn.isSelected = false
                        }
                    }
                    let title =  data["name"].stringValue
                    data["name"] = JSON("\(display["name"].stringValue) \(title)")
                }
            }
            sender.isSelected = !sender.isSelected
            self.completion?(data, sender.isSelected)
        }
    }
}

class FilterSectionView: UIView {
    @IBOutlet weak var btnSection: CButton!
    @IBOutlet weak var svGroup: UIStackView!
    @IBOutlet weak var lbSecTitle: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    
    var display:JSON!
    var listData: [JSON]?
    var type: FitlerViewType = .hasTag
    var completion:((_ data: Any?, _ isSelected:Bool)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reloadUi() {
        for subView in svGroup.subviews {
            if let groupView = subView as? FilterGropView {
                groupView.reloadUi()
            }
        }
    }
    
    func configurationData(_ display:JSON, _ listData:[JSON]?, _ type:FitlerViewType) {
        self.display = display
        self.listData = listData
        self.type = type
        lbSecTitle.text = display["name"].stringValue
        btnSection.data = false
    
        guard let listData = listData, listData.isEmpty == false else {
            return
        }
        
        let level2 = listData.filter { (item) -> Bool in
            return display["ctgr_id"].stringValue == item["up_ctgr_id"].stringValue
        }
        
        for item in level2 {
            let groupView = Bundle.main.loadNibNamed("FilterSectionView", owner: nil, options: nil)?.last as! FilterGropView
            svGroup.addArrangedSubview(groupView)
            groupView.configurationData(item, listData, self.type)
            groupView.completion = {(item, isSelected) ->Void in
                self.completion?(item, isSelected)
            }
            if (self.type == .hasTag) {
                svGroup.isHidden = true
            }
            else {
                svGroup.isHidden = false
                btnSection.isSelected = true
                if let lbTitle = btnSection.viewWithTag(100) as? UILabel {
                    lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .bold)
                }
                if let ivArrow = btnSection.viewWithTag(101) as? UIImageView {
                    ivArrow.image = UIImage(systemName: "chevron.up")
                }
            }
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender:UIButton) {
        if sender == btnSection {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                svGroup.isHidden = false
                if let lbTitle = btnSection.viewWithTag(100) as? UILabel {
                    lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .bold)
                }
                if let ivArrow = btnSection.viewWithTag(101) as? UIImageView {
                    ivArrow.image = UIImage(systemName: "chevron.up")
                }
            }
            else {
                svGroup.isHidden = true
                if let lbTitle = btnSection.viewWithTag(100) as? UILabel {
                    lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .regular)
                }
                if let ivArrow = btnSection.viewWithTag(101) as? UIImageView {
                    ivArrow.image = UIImage(systemName: "chevron.down")
                }
            }
        }
    }
}
