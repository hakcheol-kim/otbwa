//
//  ImgItemView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/28.
//

import UIKit

class ImgItemView: UIView {
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var btnOpcity: CButton!
    @IBOutlet weak var ivBadge: UIImageView!
    var index = 0
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var completion:((_ index: Int) -> Void)?
    func configurationData(_ data: UIImage, _ index:Int = 0, _ hideBadge:Bool = true, _ hideOpcity:Bool = true) {
        self.index = index
        ivThumb.image = data
        ivBadge.isHidden = hideBadge
        
        if hideOpcity == true {
            btnOpcity.backgroundColor = UIColor.clear
        }
        else {
            btnOpcity.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        }
        btnOpcity.tag = 100+index
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnOpcity {
            self.completion?(sender.tag - 100)
        }
    }
    
}
