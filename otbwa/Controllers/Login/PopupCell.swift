//
//  PopupCell.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class PopupCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView.init()
        bgView.layer.cornerRadius = 6
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = RGB(235, 235, 235).cgColor
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .bold)
            lbTitle.textColor = UIColor(named: "AccentColor")
            bgView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        }
        else {
            lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .regular)
            lbTitle.textColor = UIColor.label
            bgView.layer.borderColor = RGB(235, 235, 235).cgColor
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .bold)
            lbTitle.textColor = UIColor(named: "AccentColor")
            bgView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        }
        else {
            lbTitle.font = UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .regular)
            lbTitle.textColor = UIColor.label
            bgView.layer.borderColor = RGB(235, 235, 235).cgColor
        }
    }
}
