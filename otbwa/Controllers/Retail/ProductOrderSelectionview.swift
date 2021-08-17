//
//  ProductOrderSelectionview.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON
class ProductOrderCounterView: UIView {
    @IBOutlet var btnTitle: UIButton!
    @IBOutlet var btnMin: UIButton!
    @IBOutlet var btnMax: UIButton!
    @IBOutlet var lbCounter: UILabel!
    
    var completion:((_ index:IndexPath) ->Void)?
    var count:Int = 1 {
        didSet {
            lbCounter.text = "\(count)"
        }
    }
    
    var index:IndexPath!
    var color: JSON!
    var size: String!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ color: JSON, _ size:String, _ index:IndexPath) {
        self.index = index
        self.size = size
        self.color = color
        let title = color["value"].stringValue+" / "+size
        btnTitle.setTitle(title, for: .normal)
        self.count = 1
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMin {
            if self.count == 1 {
                return
            }
            self.count -= 1
        }
        else if sender == btnMax {
            self.count += 1
        }
        else if sender == btnTitle {
            self.completion?(index)
            self.removeFromSuperview()
        }
    }
}

class ProductOrderSelectionview: UIView {
    @IBOutlet weak var svColor: UIStackView!
    @IBOutlet weak var svSize: UIStackView!
    @IBOutlet weak var svCounterContainer: UIStackView!
    @IBOutlet weak var svCounter: UIStackView!
    
    var colors = [JSON]()
    var sizes = [String]()
    
    var selSec: Int = -1
    var selRow: Int = -1
    
    var indexPaths = [IndexPath]()
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    func configurationUi(_ data:JSON) {
        let color = data["color"].stringValue.components(separatedBy: ",")
        self.sizes = data["size"].stringValue.components(separatedBy: ",")
        
        guard let cacheFilter = UserDefaults.standard.object(forKey: Dfskey.filterCacheData) as? [String:Any] else {
            return
        }
        let filters = JSON(cacheFilter)
        let colorList = filters["data"]["color"].arrayValue
//        "value" : "멀티",
//        "code" : "80200018",
//        "rgb" : ""
        
        self.selSec = -1
        self.selRow = -1
        svCounterContainer.isHidden = true
        
        self.colors.removeAll()
        for name in color {
            let trimmedString = name.trimmingCharacters(in: .whitespaces)
            for item in colorList {
                if trimmedString == item["value"].stringValue {
                    self.colors.append(item)
                }
            }
        }
        
        for subView in svColor.subviews {
            subView.removeFromSuperview()
        }
        for subView in svSize.subviews {
            subView.removeFromSuperview()
        }
        
        var index = 100
        for item in self.colors {
            let btn = UIButton.init(type: .custom)
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
        }
        
        index = 200
        for item in self.sizes {
            let btn = UIButton.init(type: .custom)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            svSize.addArrangedSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 28).isActive = true
            
            let attrNor = NSAttributedString.init(string: item, attributes: [.foregroundColor:UIColor.label, .font: UIFont.systemFont(ofSize: 11, weight: .regular)])
            let attrSel = NSAttributedString.init(string: item, attributes: [.foregroundColor:UIColor(named: "AccentColor")!, .font: UIFont.systemFont(ofSize: 11, weight: .bold)])
            btn.setAttributedTitle(attrNor, for: .normal)
            btn.setAttributedTitle(attrSel, for: .selected)
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
            btn.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
            btn.tag = index
            index += 1
        }
    }
    
    func addCounterView(_ index:IndexPath) {
        let counter = Bundle.main.loadNibNamed("ProductOrderSelectionview", owner: nil, options: nil)?.last as! ProductOrderCounterView
        svCounterContainer.isHidden = false
        svCounter.addArrangedSubview(counter)
        
        let item = self.colors[index.section]
        let size = self.sizes[index.row]
        counter.configurationData(item, size, index)
        counter.completion = { (selIndex:IndexPath) ->Void in
            var i = 0
            for index in self.indexPaths {
                if index.section == selIndex.section && index.row == selIndex.row  {
                    self.indexPaths.remove(at: i)
                    break
                }
                i += 1
            }
            if self.indexPaths.isEmpty == true {
                self.svCounterContainer.isHidden = true
            }
        }
    }
    
    @objc func onClickedBtnActions(_ sender:UIButton) {
        if sender.tag >= 100 && sender.tag < 200 {
            for subView in svColor.subviews {
                if let btn = subView as? UIButton {
                    btn.isSelected = false
                    btn.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
                }
            }
            sender.isSelected = true
            
            sender.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            self.selSec = sender.tag - 100
            
            if self.selRow >= 0 {
                let curIndex = IndexPath(row: self.selRow, section: self.selSec)
                
                var hasItem = false
                for index in indexPaths {
                    if index.section == curIndex.section && index.row == curIndex.row {
                        hasItem = true
                    }
                }
                
                if hasItem == false {
                    self.indexPaths.append(curIndex as IndexPath)
                    self.addCounterView(curIndex)
                }
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
            
            self.selRow = sender.tag - 200
            
            if (self.selSec >= 0) {
                let curIndex = IndexPath(row: self.selRow, section: self.selSec)
                
                var hasItem = false
                for index in indexPaths {
                    if index.section == curIndex.section && index.row == curIndex.row {
                        hasItem = true
                    }
                }
                
                if hasItem == false {
                    self.indexPaths.append(curIndex as IndexPath)
                    self.addCounterView(curIndex)
                }
            }
        }
    }
    func getOrderProductInfo() -> Any? {
        guard indexPaths.isEmpty == false else {
            return nil
        }
        var array = [[String:Any]]()
        for sub in svCounter.subviews {
            if let counter = sub as? ProductOrderCounterView {
                var data = [String:Any]()
                
                let item = counter.color!
                let size = counter.size
                let count = counter.count
                
                data["color"] = item["code"].stringValue
                data["size"] = size?.trimmingCharacters(in:.whitespaces)
                data["cnt"] = count
                
                array.append(data)
            }
        }
        
        return array
    }
}
