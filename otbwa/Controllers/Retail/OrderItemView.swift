//
//  OrderItemView.swift
//  otbwa
//
//  Created by 김학철 on 2021/09/07.
//

import UIKit
import SwiftyJSON

class OrderItemView: UIView {
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTotalPrice: UILabel!
    @IBOutlet weak var svOption: UIStackView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data: JSON) {
        ivThumb.layer.cornerRadius = 6
        ivThumb.clipsToBounds = true
        
        let img = data["img"].stringValue
        let name = data["name"].stringValue
        let option = data["option"].arrayValue
        let pr_color = data["pr_color"].arrayValue
        let pr_size = data["pr_size"].arrayValue
        let total_price = data["total_price"].numberValue
        
        lbTitle.text = name
        if img.isEmpty == false {
            ivThumb.setImageCache(img)
        }
        lbTotalPrice.text = total_price.toString()
        
        svOption.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        
        for item in option {
            let cnt = item["cnt"].numberValue
            let color = item["color"].stringValue
            let size = item["size"].stringValue
            
            let lb = UILabel()
            svOption.addArrangedSubview(lb)
            lb.textColor = RGB(136, 136, 136)
            lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            lb.setContentHuggingPriority(UILayoutPriority(rawValue: 800), for: .vertical)
            lb.text = color+"/"+size+"/수량 \(cnt.toString())개"
            
        }
    }
}
