//
//  OrderCounterView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/18.
//

import UIKit
import SwiftyJSON
enum OrderCounterAction: Int {
    case add, sub, del
}


class OrderCounterView: UIView {
    @IBOutlet var btnTitle: UIButton!
    @IBOutlet var btnMin: UIButton!
    @IBOutlet var btnMax: UIButton!
    @IBOutlet var lbCounter: UILabel!

    var completion:((_ option:JSON, _ action:OrderCounterAction) ->Void)?
    var count:Int = 1 {
        didSet {
            lbCounter.text = "\(count)"
        }
    }
    
    var option: JSON!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ option:JSON) {
        
        self.option = option
        self.count = option["cnt"].intValue
        
        let title = option["color"].stringValue+" / "+option["size"].stringValue
        btnTitle.setTitle(title, for: .normal)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMin {
            if self.count == 1 {
                return
            }
            self.count -= 1
            option["cnt"] = JSON(count)
            self.completion?(option, .sub)
        }
        else if sender == btnMax {
            self.count += 1
            option["cnt"] = JSON(count)
            self.completion?(option, .add)
        }
        else if sender == btnTitle {
            self.completion?(option, .del)
            self.removeFromSuperview()
        }
    }
}
