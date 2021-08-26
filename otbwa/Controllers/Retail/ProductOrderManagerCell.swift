//
//  ProductOrderManagerCell.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit
import SwiftyJSON
class ProductOrderManagerCell: UITableViewCell {
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var svBtn: UIStackView!
    @IBOutlet weak var svContent: UIStackView!
    
    var building:[JSON]!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configurationData(_ data: JSON, _ selBuilding: String? = nil) {

        lbDate.text = data["date"].stringValue
        self.building = data["building"].arrayValue
        
        for subView in svBtn.subviews {
            subView.removeFromSuperview()
        }
        var index = 0
        var selIndex = 0
        for bItem in building {
            let btn = SelectedButton.init(frame: .zero)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            btn.cornerRadius = 6
            btn.tl = true
            btn.tr = true
            btn.bl = true
            btn.br = true
            btn.borderWidth = 1
            btn.borderColor = RGB(235, 235, 235)
            btn.selBorderColor = UIColor(named: "AccentColor")!
            let name = bItem["name"].stringValue
            
            btn.setTitle(name, for: .normal)
            btn.decorationNormalBtn()
            
            btn.data = bItem["order"].arrayValue
            
            svBtn.addArrangedSubview(btn)
            btn.tag = 100+index
            index += 1
            if let selBuilding = selBuilding, selBuilding == name {
                selIndex = index
            }
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        
        if let selBtn = svBtn.viewWithTag(100+selIndex) as? SelectedButton {
            selBtn.sendActions(for: .touchUpInside)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if let sender = sender as? SelectedButton {
            for subView in svBtn.subviews {
                if let btn = subView as? SelectedButton {
                    btn.isSelected = false
                }
            }
            sender.isSelected = true
            let index = sender.tag - 100
            let selBuild = building[index]["name"].stringValue
            
            
            guard let data = sender.data as? [JSON] else {
                return
            }
            for sub in svContent.subviews {
                sub.removeFromSuperview()
            }
            
            var i = 0
            for item in data {
                let itemView = Bundle.main.loadNibNamed("POMItemView", owner: nil, options: nil)?.first as! POMItemView
                svContent.addArrangedSubview(itemView)
                if i == 0 {
                    itemView.seperatorView.isHidden = true
                }
                else {
                    itemView.seperatorView.isHidden = false
                }
                itemView.configurationData(item)
                i += 1
            }
        }
    }
}
