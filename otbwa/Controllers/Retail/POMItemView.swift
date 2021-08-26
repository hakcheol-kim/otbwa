//
//  POMItemView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit
import SwiftyJSON

class POMItemView: UIView {
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbOrderNumber: UILabel!
    @IBOutlet weak var lbProductCnt: UILabel!
    @IBOutlet weak var lbAddr: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var btnState: CButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivThumb.layer.cornerRadius = 6
    }

    func configurationData(_ data: JSON) {
        let order_no = data["order_no"].stringValue
        let order_status = data["order_status"].stringValue
        let img = data["img"].stringValue
        let order_key = data["order_key"].numberValue
        let total_price = data["total_price"].numberValue
        let addr = data["addr"].stringValue
        let title = data["title"].stringValue
        
        ivThumb.image = nil
        if img.isEmpty == false {
            ivThumb.setImageCache(img)
        }
        lbOrderNumber.text = "주문번호 : \(order_no)"
        lbProductCnt.text = title
        lbAddr.text = addr
        if order_status.localizedLowercase == "waiting" {
            btnState.backgroundColor = RGB(125, 125, 125)
        }
        else {
            btnState.backgroundColor = RGB(103, 186, 6)
        }
        
        lbAmount.text = total_price.toString()+"원"
    }
}
