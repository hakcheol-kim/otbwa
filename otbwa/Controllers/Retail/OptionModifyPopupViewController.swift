//
//  OptionModifyPopupViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/18.
//

import UIKit
import SwiftyJSON
class OptionModifyPopupViewController: BaseViewController {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lbCompName: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbTotalAmount: UILabel!
    @IBOutlet weak var optionBgView: UIView!
    
    var data: JSON!
    var completion:((_ options:[JSON]) -> Void)?
    var orderSelectionView: OrderSelectionView!
    var options = [JSON]()
    
    static func initWithData(_ data:JSON, _ completion:((_ options:[JSON]) -> Void)?) -> OptionModifyPopupViewController {
        let vc = OptionModifyPopupViewController.instantiateFromStoryboard(.main)!
        
        vc.completion = completion
        vc.data = data
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        lbCompName.text = data["name"].stringValue
        lbAmount.text = data["price"].numberValue.toString()
        lbTotalAmount.text = data["total_price"].numberValue.toString()
        
        let pr_color = data["pr_color"].arrayValue
        let pr_size = data["pr_size"].arrayValue
        self.options = data["option"].arrayValue
        
        orderSelectionView = Bundle.main.loadNibNamed("OrderSelectionView", owner: nil, options: nil)?.first as? OrderSelectionView
        optionBgView.addSubview(orderSelectionView!)
        orderSelectionView.addConstraintsSuperView(.zero)
        orderSelectionView.svColoerContainer.axis = .vertical
        orderSelectionView.svColoerContainer.spacing = 8
        orderSelectionView.svSizeContainer.axis = .vertical
        orderSelectionView.svSizeContainer.spacing = 8
        orderSelectionView.svOptionContainer.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        orderSelectionView.svCounter.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        orderSelectionView.configurationData(pr_color, pr_size, self.options)
        
        orderSelectionView.completion = {options ->Void in
            self.options = options
            if self.options.isEmpty == false {
                print(self.options)
                var sum = 0
                for op in self.options {
                    sum += op["cnt"].intValue * self.data["price"].intValue
                }
                self.lbTotalAmount.text = "\(sum)".addComma()
            }
            else {
                self.lbTotalAmount.text = "0"
            }
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnClose {
            self.dismiss(animated: true, completion: nil)
        }
        else if sender == btnSave {
            self.completion?(self.options)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
