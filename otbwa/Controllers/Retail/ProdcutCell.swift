//
//  ProdcutCell.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class ProdcutCell: UITableViewCell {
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet var ivThumb: UIImageView!
    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var lbSubTitle: UILabel!
    @IBOutlet var lbAmount: UILabel!
    @IBOutlet weak var btnCheck: UIButton!
    var data:JSON!
    var type: TableViewType = .normal
    var completion:((_ item: JSON, _ isSelected:Bool) ->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        ivThumb.layer.cornerRadius = 6
        ivThumb.clipsToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configuratonData(_ data: JSON, _ type:TableViewType = .normal, _ isSelected:Bool = false) {
        self.data = data
        let comp_addr = data["comp_addr"].stringValue
//        let comp_nm = data["comp_nm"].stringValue
//        let comp_no = data["comp_no"].stringValue
        let img = data["img"].stringValue
        let price = data["price"].numberValue
        let product_nm = data["product_nm"].stringValue
//        let product_no = data["product_no"].stringValue
        let addr = data["addr"].stringValue
        lbTitle.text = product_nm
        
        lbSubTitle.text = ""
        if comp_addr.isEmpty == false {
            lbSubTitle.text = comp_addr
        }
        else if addr.isEmpty == false {
            lbSubTitle.text = addr
        }
        
        lbAmount.text = price.toString()+"원"
        if img.isEmpty == false {
            var userInfo = [String : Any]()
            userInfo["targetView"] = ivThumb
            
            Utility.downloadImage(img, userInfo) { (image, info) in
                guard let image = image, let info = info as? [String : Any], let targetView = info["targetView"] as? UIImageView else {
                    return
                }
                
                targetView.image = image
                if image.size.width > image.size.height {
                    //w:h = iw:ih
                    let h = (80*image.size.height)/image.size.width
                    targetView.frame = CGRect(x: 0, y: (80-h)/2, width: 80, height: h)
                }
                else {
                    //w:h = iw:ih
                    let w = (80*image.size.width)/image.size.height
                    targetView.frame = CGRect(x: (80-w)/2, y:0 , width: w, height: 80)
                }
            }
        }
        btnCheck.isSelected = isSelected
        if type == .edit {
            btnCheck.isHidden = false
            svContent.layoutMargins = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 0)
        }
        else {
            btnCheck.isHidden = true
            svContent.layoutMargins = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCheck {
            sender.isSelected = !sender.isSelected
            self.completion?(data, sender.isSelected)
        }
    }
}
