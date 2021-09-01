//
//  WProductColCell.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON

class WProductColCell: UICollectionViewCell {
    @IBOutlet weak var ivBadge: UIImageView!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnSoldOut: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configurationData(_ data: JSON, _ listType:ListType = .normal, _ isCheckOn:Bool = false) {
        
        let img = data["img"].stringValue
        let name = data["name"].stringValue
        let price = data["price"].numberValue
        let views = data["views"].numberValue
        let status = data["status"].stringValue //approved, waiting, reject
        
        ivBadge.isHidden = true
        btnSoldOut.isHidden = true
        btnCheck.isHidden = true
        lbName.textColor = UIColor.label
        lbPrice.textColor = RGB(167, 167, 167)
        
        btnCheck.isSelected = isCheckOn
        btnCheck.isHidden = !(listType == .editing)
        
        if status == "waiting" {
            ivBadge.isHidden = false
        }
        else if status == "soldout" {
            btnSoldOut.isHidden = false
            lbName.textColor = RGB(191, 191, 191)
            lbPrice.textColor = RGB(191, 191, 191)
        }
        
        lbName.text = name
        ivThumb.image = nil
        if img.isEmpty == false {
            ivThumb.setImageCache(img)
        }
        btnEye.setTitle(views.toString(), for: .normal)
        btnLike.setTitle("0", for: .normal)
        lbPrice.text = price.toString()+"원"
        
    }
}

