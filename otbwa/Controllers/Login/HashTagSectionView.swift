//
//  HashTagSectionView.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/31.
//

import UIKit
import SwiftyJSON
class HashTagGroupView: UIView {
    @IBOutlet weak var btnGroupTitle: UIButton!
    @IBOutlet weak var svList: UIStackView!
    
    var completion:(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ display: JSON, _ completion:(()->Void)?) {
        
        btnGroupTitle.setTitle(display["name"].stringValue, for: .normal)
        self.completion = completion
        
        guard let data = ShareData.ins.objectForKey("filters") as? JSON else {
            return
        }
        let category = data["category"].arrayValue
        let level3 = category.filter { (item) -> Bool in
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
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnGroupTitle {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                svList.isHidden = false
            }
            else {
                svList.isHidden = true
            }
        }
        else if let sender = sender as? CButton {
            guard let title = sender.titleLabel?.attributedText?.string else {
                return
            }
            guard let data = sender.data as? JSON else {
                return
            }
            
            if ShareData.ins.objectForKey("hashtags") == nil {
                let list = [JSON]()
                ShareData.ins.setObject(list, forKey: "hashtags")
            }
            
            var tags = ShareData.ins.objectForKey("hashtags") as! [JSON]
            
            if sender.isSelected {
                if let index = tags.firstIndex(of: data) {
                    tags.remove(at: index)
                    sender.isSelected = false
                }
            }
            else if sender.isSelected == false {
                guard tags.count < 3 else {
                    appDelegate.window!.makeToast("해시태그는 최대 3개까지 선택할 수 있습니다.")
                    return
                }
                sender.isSelected = true
                tags.append(data)
            }
            ShareData.ins.setObject(tags, forKey: "hashtags")
            self.completion?()
        }
    }
}

class HashTagSectionView: UIView {
    @IBOutlet weak var btnSection: CButton!
    @IBOutlet weak var svGroup: UIStackView!
    @IBOutlet weak var lbSecTitle: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    var display:JSON!
    
    var completion:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ display:JSON, _ completion:(()->Void)?) {
//        ["sec_name": "남성 신발",
//         "sec_list":[["group":"구두", "group_list":["정장구두", "힐"]],
//                     ["group":"운동화", "group_list":["런닝화", "캐쥬얼"]],
//                     ["group":"슬리퍼", "group_list":["슬피퍼", "샌들"]]]]
        self.display = display
        self.completion = completion
        
        lbSecTitle.text = display["name"].stringValue
        btnSection.data = false
        
        guard let data = ShareData.ins.objectForKey("filters") as? JSON else {
            return
        }
        let category = data["category"].arrayValue
        let level2 = category.filter { (item) -> Bool in
            return display["ctgr_id"].stringValue == item["up_ctgr_id"].stringValue
        }
        
        for item in level2 {
            let groupView = Bundle.main.loadNibNamed("HashTagSectionView", owner: nil, options: nil)?.last as! HashTagGroupView
            groupView.configurationData(item) {
                self.completion?()
            }
            svGroup.addArrangedSubview(groupView)
            svGroup.isHidden = true
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
