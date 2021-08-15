//
//  BannerColCell.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit
import SwiftyJSON
class BannerColCell: UICollectionViewCell {
    @IBOutlet weak var ivThumb: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configurationData(_ data:JSON) {
        let banner_img = data["banner_img"].stringValue
        if banner_img.isEmpty == false {
            ivThumb.setImageCache(banner_img)
        }
//        ivThumb.layer.borderWidth = 1
//        ivThumb.layer.borderColor = UIColor.red.cgColor
    }
}
