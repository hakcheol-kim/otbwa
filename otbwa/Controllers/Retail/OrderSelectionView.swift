//
//  OrderSelectionview.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class OrderSelectionView: UIView {
    @IBOutlet weak var svOptionContainer: UIStackView!
    @IBOutlet weak var svColoerContainer: UIStackView!
    @IBOutlet weak var svColor: UIStackView!
    @IBOutlet weak var svSizeContainer: UIStackView!
    @IBOutlet weak var svSize: UIStackView!
    @IBOutlet weak var svCounterContainer: UIStackView!
    @IBOutlet weak var svCounter: UIStackView!
    
    private var colors = [JSON]()
    private var sizes = [JSON]()
    var options = [JSON]()
    
    private var selBtnColor: CButton?
    private var selBtnSize: CButton?
 
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    var completion:((_ options:[JSON]) -> Void)?
    
    func configurationData(_ colors:[JSON], _ sizes:[JSON], _ options:[JSON]? = nil) {
        self.colors = colors
        self.sizes = sizes
        
        if let options = options {
            svCounterContainer.isHidden = false
            for op in options {
                var color = JSON()
                color["value"] = op["color"]
                color["code"] = op["color_code"]
                color["basket_no"] = op["basket_no"]
                self.addCounterView(color, op["size"], op["cnt"].intValue)
            }
        }
        else {
            svCounterContainer.isHidden = true
        }
        for subView in svColor.subviews {
            subView.removeFromSuperview()
        }
        for subView in svSize.subviews {
            subView.removeFromSuperview()
        }
        
        var index = 100
        for item in self.colors {
            let btn = CButton.init(type: .custom)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            svColor.addArrangedSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 28).isActive = true
            let title = item["value"].stringValue
            let attrNor = NSAttributedString.init(string: title, attributes: [.foregroundColor:UIColor.label, .font: UIFont.systemFont(ofSize: 11, weight: .regular)])
            let attrSel = NSAttributedString.init(string: title, attributes: [.foregroundColor:UIColor(named: "AccentColor")!, .font: UIFont.systemFont(ofSize: 11, weight: .bold)])
            btn.setAttributedTitle(attrNor, for: .normal)
            btn.setAttributedTitle(attrSel, for: .selected)
            
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
            
            btn.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
            btn.tag = index
            index += 1
            btn.data = item
        }
        
        index = 200
        
        for item in self.sizes {
            let btn = CButton.init(type: .custom)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            svSize.addArrangedSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 28).isActive = true
            
            let attrNor = NSAttributedString.init(string: item.stringValue, attributes: [.foregroundColor:UIColor.label, .font: UIFont.systemFont(ofSize: 11, weight: .regular)])
            let attrSel = NSAttributedString.init(string: item.stringValue, attributes: [.foregroundColor:UIColor(named: "AccentColor")!, .font: UIFont.systemFont(ofSize: 11, weight: .bold)])
            btn.setAttributedTitle(attrNor, for: .normal)
            btn.setAttributedTitle(attrSel, for: .selected)
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
            btn.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
            btn.tag = index
            index += 1
            btn.data = item
        }
    }
    
    func addCounterView(_ color:JSON, _ size:JSON, _ cnt:Int = 1) {
        let counter = Bundle.main.loadNibNamed("OrderCounterView", owner: nil, options: nil)?.last as! OrderCounterView
        svCounterContainer.isHidden = false
        svCounter.addArrangedSubview(counter)
        
        var op = JSON()
        op["color"] = color["value"]
        op["color_code"] = color["code"]
        op["basket_no"] = color["basket_no"]
        op["size"] = size
        op["cnt"] = JSON(cnt)
        
        self.options.append(op)
        
        counter.configurationData(op)
        counter.completion = { (option: JSON, action: OrderCounterAction) ->Void in
            if action == .add {
                self.replaceOption(option)
                self.completion?(self.options)
            }
            else if action == .sub {
                self.replaceOption(option)
                self.completion?(self.options)
            }
            else if action == .del {
                self.deleteOption(option)
                self.completion?(self.options)
                if self.options.isEmpty == true {
                    self.svCounterContainer.isHidden = true
                }
            }
        }
        self.completion?(self.options)
    }
    
    func deleteOption(_ option:JSON) {
        for i in 0..<self.options.count {
            let op = options[i]
            if option["color_code"].stringValue == op["color_code"].stringValue && option["size"].stringValue == op["size"].stringValue {
                self.options.remove(at: i)
                break
            }
        }
    }
    
    func replaceOption(_ option:JSON) {
        for i in 0..<self.options.count {
            let op = options[i]
            if option["color_code"].stringValue == op["color_code"].stringValue && option["size"].stringValue == op["size"].stringValue {
                self.options[i] = option
                break
            }
        }
    }
    func containsOption(_ colorCode:String, _ size:String) ->Bool {
        var isHas = false
        for item in self.options {
            if colorCode == item["color_code"].stringValue && size == item["size"].stringValue {
                isHas = true
                break
            }
        }
        return isHas
    }
    
    @objc func onClickedBtnActions(_ sender: CButton) {
        if sender.tag >= 100 && sender.tag < 200 {
            for subView in svColor.subviews {
                if let btn = subView as? UIButton {
                    btn.isSelected = false
                    btn.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
                }
            }
            sender.isSelected = true
            sender.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            
            self.selBtnColor = sender
            guard let selBtnColor = self.selBtnColor, let color = selBtnColor.data as? JSON else {
                return
            }
            guard let selBtnSize = self.selBtnSize, let size = selBtnSize.data as? JSON else {
                return
            }
            
            if containsOption(color["code"].stringValue, size.stringValue) == false {
                self.addCounterView(color, size)
            }
        }
        else if sender.tag >= 200 {
            for subView in svSize.subviews {
                if let btn = subView as? UIButton {
                    btn.isSelected = false
                    btn.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
                }
            }
            
            sender.isSelected = true
            sender.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            
            self.selBtnSize = sender
            guard let selBtnColor = self.selBtnColor, let color = selBtnColor.data as? JSON else {
                return
            }
            guard let selBtnSize = self.selBtnSize, let size = selBtnSize.data as? JSON else {
                return
            }
            
            if containsOption(color["code"].stringValue, size.stringValue) == false {
                self.addCounterView(color, size)
            }
        }
    }
}
