//
//  StoreInfoHearderView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/19.
//

import UIKit
import SwiftyJSON

class StoreInfoHearderView: UICollectionReusableView {
    @IBOutlet weak var ivthumb: UIImageView!
    @IBOutlet weak var lbCompNm: UILabel!
    @IBOutlet weak var lbAddr: UILabel!
    @IBOutlet weak var btnTel: UIButton!
    @IBOutlet weak var btnNotice: UIButton!
    @IBOutlet weak var btnPartner: UIButton!
    @IBOutlet weak var tfProductSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnProductOrder: CButton!
    @IBOutlet weak var tfProductOrder: UITextField!
    @IBOutlet weak var btnCheckPartner: UIButton!
    @IBOutlet weak var svTags: UIStackView!
    
    var data: JSON!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var completion:((_ action:Int, _ item: Any?) ->Void)?
    
    func configurationData(_ data: JSON) {
        self.data = data
        let name = data["name"].stringValue
        let addr = data["addr"].stringValue
        let tel = data["tel"].stringValue
        let hashtag = data["hashtag"].stringValue
        lbCompNm.text = name
        lbAddr.text = addr
        btnTel.setTitle(tel, for: .normal)
        
        btnNotice.layer.cornerRadius = btnNotice.bounds.height/2
        btnPartner.layer.cornerRadius = btnPartner.bounds.height/2
        btnNotice.layer.maskedCorners = CACornerMask(TL: true, TR: false, BL: true, BR: false)
        btnPartner.layer.maskedCorners = CACornerMask(TL: true, TR: false, BL: true, BR: false)
        
        for subView in svTags.subviews {
            subView.removeFromSuperview()
        }
        
        let arrTag = hashtag.components(separatedBy: ",")
        for tag in arrTag {
            let tag = tag.trimmingCharacters(in: .whitespaces)
            let btnTag = UIButton.init(type: .custom)
            svTags.addArrangedSubview(btnTag)
            
            btnTag.setTitle("#\(tag)", for: .normal)
            btnTag.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            btnTag.backgroundColor = RGB(241, 241, 241)
            btnTag.layer.cornerRadius = 12
            btnTag.translatesAutoresizingMaskIntoConstraints = false
            btnTag.heightAnchor.constraint(equalToConstant: 24).isActive = true
            btnTag.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            btnTag.setTitleColor(RGB(136 , 136, 136), for: .normal)
            btnTag.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSearch {
            tfProductSearch.becomeFirstResponder()
        }
        else if sender == btnNotice {
            self.completion?(100, nil)
        }
        else if sender == btnPartner {
            self.completion?(101, nil)
        }
        else if sender == btnTel {
            let tel = data["tel"].stringValue
            self.completion?(102, tel)
        }
        else if sender == btnCheckPartner {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.completion?(103, "client")
            }
            else {
                self.completion?(103, "all")
            }
        }
        else if sender == btnProductOrder {
            self.completion?(104, nil)
        }
    }
}
