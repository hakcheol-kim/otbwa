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
    
    func configurationData(_ data: JSON, _ completion:(()->Void)?) {
    
        
//        ["group":"구두", "group_list":["정장구두", "힐"]]
        btnGroupTitle.setTitle(data["group"].stringValue, for: .normal)
        self.completion = completion
        
        for item in data["group_list"].arrayValue {
            let btn = UIButton.init()
            btn.contentHorizontalAlignment = .left
            let title = item.stringValue
            let attrNor = NSAttributedString.init(string: title, attributes: [.font : UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor : UIColor.label])
            btn.setAttributedTitle(attrNor, for: .normal)
            let attrSel = NSAttributedString.init(string: title, attributes: [.font : UIFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor : UIColor(named: "AccentColor")!])
            btn.setAttributedTitle(attrSel, for: .selected)
            svList.addArrangedSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
            
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
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
        else {
            guard let title = sender.titleLabel?.attributedText?.string else {
                return
            }
            
            if sender.isSelected {
                if let index = ShareData.ins.hashTags.firstIndex(of: title) {
                    ShareData.ins.hashTags.remove(at: index)
                    sender.isSelected = false
                }
            }
            else if sender.isSelected == false {
                guard ShareData.ins.hashTags.count < 3 else {
                    appDelegate.window!.makeToast("해시태그는 최대 3개까지 선택할 수 있습니다.")
                    return
                }
                sender.isSelected = true
                ShareData.ins.hashTags.append(title)
            }
            self.completion?()
        }
    }
}

class HashTagSectionView: UIView {
    @IBOutlet weak var btnSection: CButton!
    @IBOutlet weak var svGroup: UIStackView!
    @IBOutlet weak var lbSecTitle: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    
    var completion:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data:JSON, _ completion:(()->Void)?) {
//        ["sec_name": "남성 신발",
//         "sec_list":[["group":"구두", "group_list":["정장구두", "힐"]],
//                     ["group":"운동화", "group_list":["런닝화", "캐쥬얼"]],
//                     ["group":"슬리퍼", "group_list":["슬피퍼", "샌들"]]]]
        self.completion = completion
        lbSecTitle.text = data["sec_name"].stringValue
        let arrGroup = data["sec_list"].arrayValue
        btnSection.data = false
        
        for group in arrGroup {
            let groupView = Bundle.main.loadNibNamed("HashTagSectionView", owner: nil, options: nil)?.last as! HashTagGroupView
            groupView.configurationData(group) {
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
            }
            else {
                svGroup.isHidden = true
            }
        }
    }
}
