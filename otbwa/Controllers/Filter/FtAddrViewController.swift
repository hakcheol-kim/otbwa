//
//  FtAddrViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/10.
//

import UIKit
import SwiftyJSON

class FtAddrViewController: BaseViewController {
    @IBOutlet weak var svContent: UIStackView!
    
    @IBOutlet weak var btnSave: CButton!
    @IBOutlet weak var btnReset: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    var listData: [JSON]!
    var configData:[JSON]?
    var completion:((_ item:Any?, _ action:Int) ->Void)?
    
    static func initWithData(_ data:[JSON], _ configData:[JSON]?, completion:((_ item: Any?, _ action:Int) ->Void)?) -> FtAddrViewController {
        let vc = FtAddrViewController.instantiateFromStoryboard(.common)!
        vc.completion = completion
        vc.configData = configData
        vc.listData = data
        
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attrN = NSAttributedString.init(string: "상가 초기화", attributes: [.foregroundColor:RGB(160, 160, 160), .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        let attrS = NSAttributedString.init(string: "상가 초기화", attributes: [.foregroundColor:UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        
        btnReset.setAttributedTitle(attrN, for: .normal)
        btnReset.setAttributedTitle(attrS, for: .selected)
        btnReset.setBackgroundImage(UIImage.color(from: RGB(233, 233, 233)), for: .normal)
        btnReset.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .selected)
        
        safetyView.isHidden = !isEdgePhone
        
        configurationUi()
    }
    
    func configurationUi() {
        let level1 = listData.filter { item -> Bool in
            return item["level"].stringValue == "1"
        }
        for subView in svContent.subviews {
            subView.removeFromSuperview()
        }
        ShareData.ins.selectedFilterList.removeAll()
        
        for item in level1 {
            let tagView = Bundle.main.loadNibNamed("FilterSectionView", owner: nil, options: nil)?.first as! FilterSectionView
            svContent.addArrangedSubview(tagView)
            
            tagView.configurationData(item, listData, .address)
            tagView.completion = {(data, isSelected) ->Void in
                guard let data = data as? JSON else {
                    return
                }
                if let index = ShareData.ins.selectedFilterList.firstIndex(of: data) {
                    ShareData.ins.selectedFilterList.remove(at: index)
                    self.completion?(data, 3)
                }
                else {
                    ShareData.ins.selectedFilterList.removeAll()
                    ShareData.ins.selectedFilterList.append(data)
                    self.completion?(data, 3)
                }
                self.reloadUi()
                self.btnReset.isSelected = !(ShareData.ins.selectedFilterList.isEmpty)
            }
            tagView.layer.cornerRadius = 6
            tagView.clipsToBounds = true
            tagView.layer.borderWidth = 1
            tagView.layer.borderColor = RGB(235, 235, 235).cgColor
        }
    }
    
    func reloadUi() {
        for subView in svContent.subviews {
            if let subView = subView as? FilterSectionView {
                subView.reloadUi()
            }
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSave {
            self.completion?(ShareData.ins.selectedFilterList.last, 1)
        }
        else if sender == btnReset {
            ShareData.ins.selectedFilterList.removeAll()
            self.completion?(nil, 2)
        }
    }

}
