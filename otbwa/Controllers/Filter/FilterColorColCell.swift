//
//  FilterColorColCell.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/11.
//

import UIKit
import SwiftyJSON
class FilterColorColCell: UICollectionViewCell {

    @IBOutlet weak var selectedBtn: SelectedButton!
    @IBOutlet weak var ivColor: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivColor.layer.cornerRadius = ivColor.bounds.size.height/2;
    }
    
    func configurationData(_ item:JSON!, _ isSelected:Bool) {
        let rgb = item["rgb"].stringValue
        ivColor.image = nil
        
        if rgb.isEmpty == false {
            ivColor.backgroundColor = Utility.hexStringToUIColor(rgb)
        }
        else {
            ivColor.image = UIImage(named: "img_multi_color")
        }
        
        lbTitle.text = item["value"].stringValue
        if rgb.lowercased() == "#ffffff" {
            ivColor.layer.borderColor = RGB(209, 209, 209).cgColor
            ivColor.layer.borderWidth = 1
        }
        else {
            ivColor.layer.borderColor = UIColor.clear.cgColor
            ivColor.layer.borderWidth = 0
        }
        
        if isSelected {
            selectedBtn.isSelected = true
            lbTitle.textColor = UIColor(named: "AccentColor")!
            lbTitle.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        }
        else {
            selectedBtn.isSelected = false
            lbTitle.textColor = UIColor.label
            lbTitle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }
    }
}
