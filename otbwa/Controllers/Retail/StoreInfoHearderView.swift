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
    @IBOutlet weak var btnProductSelect: CButton!
    @IBOutlet weak var btnCheckPartner: UIButton!

    var data: JSON!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data: JSON) {
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
}
