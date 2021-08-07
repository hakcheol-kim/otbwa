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
    
    var completion:((_ items:Any) ->Void)?
   
    static func initWithCompletion(completion:((_ items:Any) ->Void)?) ->HashTagViewController {
        let vc = HashTagViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNext.setBackgroundImage(UIImage.color(from: RGB(203, 203, 203)), for: .disabled)
        btnNext.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .normal)
        
        btnNext.isEnabled = false
        safetyView.isHidden = !isEdgePhone
        
        
        ShareData.ins.removeObject(forKey: "hashtags")
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
            let data = res["data"]
            if success && data.isEmpty == false {
                ShareData.ins.setObject(data, forKey: "filters")
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
        guard let data = ShareData.ins.objectForKey("filters") as? JSON else {
            return
        }
        let category = data["category"].arrayValue
        let level1 = category.filter { (item) ->Bool in
            return item["level"].stringValue == "1"
        }
        
        for item in  level1 {
            let tagView = Bundle.main.loadNibNamed("HashTagSectionView", owner: nil, options: nil)?.first as! HashTagSectionView
            svContent.addArrangedSubview(tagView)
            tagView.configurationData(item) {
                if let tags = ShareData.ins.objectForKey("hashtags") as? [JSON], tags.isEmpty == false {
                    self.btnNext.isEnabled = true
                }
                else {
                    self.btnNext.isEnabled = false
                }
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
            guard let tags = ShareData.ins.objectForKey("hashtags") as? [JSON] else {
                return
            }
            self.completion?(tags)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
