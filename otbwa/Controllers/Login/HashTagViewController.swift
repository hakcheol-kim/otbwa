//
//  HashTagViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/31.
//

import UIKit
import SwiftyJSON

class HashTagViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var btnCose: UIButton!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var safetyView: UIView!

    var type: FitlerViewType = .hastagThree
    
    var completion:((_ items:Any?) ->Void)?
    var filters:JSON!
    static func initWithType(_ type:FitlerViewType, completion:((_ items:Any) ->Void)?) ->HashTagViewController {
        let vc = HashTagViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNext.setBackgroundImage(UIImage.color(from: RGB(203, 203, 203)), for: .disabled)
        btnNext.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .normal)
        
        btnNext.isEnabled = false
        safetyView.isHidden = !isEdgePhone
        ShareData.ins.selectedFilterList.removeAll()
        self.requestFilter()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    func requestFilter() {
        ApiManager.ins.requestFilterList { res in
            let success = res["success"].boolValue
            if let data = res["data"] as? JSON, data.isEmpty == false, success == true {
                self.filters = data
                self.decorationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func decorationUi() {
        for subView in svContent.subviews {
            subView.removeFromSuperview()
        }
        
        let category = filters["category"].arrayValue
        let level1 = category.filter { (item) ->Bool in
            return item["level"].stringValue == "1"
        }
    
        for item in  level1 {
            let tagView = Bundle.main.loadNibNamed("FilterSectionView", owner: nil, options: nil)?.first as! FilterSectionView
            svContent.addArrangedSubview(tagView)
            tagView.configurationData(item, category, type)
            tagView.completion = {(data, isSelected) ->Void in
                guard let data = data as? JSON else {
                    return
                }
                if let index = ShareData.ins.selectedFilterList.firstIndex(of: data) {
                    ShareData.ins.selectedFilterList.remove(at: index)
                }
                else {
                    ShareData.ins.selectedFilterList.append(data)
                }
                self.btnNext.isEnabled = !(ShareData.ins.selectedFilterList.isEmpty)
                print(ShareData.ins.selectedFilterList)
            }
            
            tagView.layer.cornerRadius = 6
            tagView.clipsToBounds = true
            tagView.layer.borderWidth = 1
            tagView.layer.borderColor = RGB(235, 235, 235).cgColor
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCose {
            self.dismiss(animated: true, completion: nil)
        }
        else if sender == btnNext {
            let tags = ShareData.ins.selectedFilterList
            self.completion?(tags)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
