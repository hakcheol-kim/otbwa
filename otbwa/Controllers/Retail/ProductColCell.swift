//
//  ProductColCell.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit
import SwiftyJSON

class ProductColCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbLikeCnt: UILabel!

    static let identifier = "ProductColCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 6
        ivThumb.layer.cornerRadius = 6
        ivThumb.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
    }
    func configurationData(_ data:JSON) {
        var name = data["name"].stringValue
        let price = data["price"].numberValue
        let likes = data["likes"].numberValue
        let img = data["img"].stringValue
        let product_nm = data["product_nm"].stringValue
        if name.isEmpty == true {
            name = product_nm
        }
        lbProductName.text = name
        lbAmount.text = "\(price.stringValue.addComma())원"
        lbLikeCnt.text = likes.stringValue.addComma()
        
        if img.isEmpty == false {
            ivThumb.setImageCache(img)
        }
        
    }
}
