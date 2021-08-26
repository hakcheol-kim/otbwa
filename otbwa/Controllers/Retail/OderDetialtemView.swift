//
//  OrderDetialtemView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit
import SwiftyJSON

class OrderPriceItem: UIView {
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbCnt: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbTotalPrice: UILabel!
    
    var data: JSON!
    var completion:((_ item:JSON?, _ isSelected:Bool) ->Void)?
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data: JSON) {
        self.data = data
        let color = data["color"].stringValue
        let size = data["size"].stringValue
        let cnt = data["cnt"].numberValue
        let price = data["price"].numberValue
        let total_price = data["total_price"].numberValue
        
        btnCheck.setTitle("\(color)/\(size)", for: .normal)
        lbCnt.text = cnt.stringValue
        lbPrice.text = price.toString()+"원"
        lbTotalPrice.text = total_price.toString()+"원"
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        self.completion?(data, sender.isSelected)
    }
}

class OrderDetialtemView: UIView {
    
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbProdName: UILabel!
    @IBOutlet weak var svPrice: UIStackView!
    @IBOutlet weak var lbTotalPrice: UILabel!
    
    var data: [JSON] = []
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data: [JSON]) {
        
        let item = data.first!
        
        let name = item["name"].stringValue
        let img = item["img"].stringValue
        
        lbProdName.text = name
        ivThumb.image = nil
        if img.isEmpty == false {
            ivThumb.setImageCache(img)
        }
        
        for sub in svPrice.subviews {
            sub.removeFromSuperview()
        }
        
        var sum = 0
        for item in data {
            let priceView = Bundle.main.loadNibNamed("OrderDetialtemView", owner: nil, options: nil)?.last as! OrderPriceItem
            svPrice.addArrangedSubview(priceView)
            priceView.configurationData(item)
            let total_price = item["total_price"].intValue
            sum += total_price
        }
        
        lbTotalPrice.text = "\(sum)".addComma()
    }
}
