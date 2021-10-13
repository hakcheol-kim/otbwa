//
//  WProductDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/27.
//

import UIKit
import SwiftyJSON
import WSTagsField

class WProductDetailViewController: BaseViewController {
    @IBOutlet weak var btnModify: CButton!
    @IBOutlet weak var btnSoldout: CButton!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var btnSoldoutStatus: UIButton!
    
    @IBOutlet weak var svBottomContainer: UIStackView!
    @IBOutlet weak var safetyView: UIView!
    
    //scrollView
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svImg: UIStackView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbProductKind: UILabel!
    @IBOutlet weak var btnViews: UIButton!
    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbColor: UILabel!
    @IBOutlet weak var lbSize: UILabel!
    @IBOutlet weak var lbMaterial: UILabel!
    @IBOutlet weak var lbCountry: UILabel!
    @IBOutlet weak var lbPieceYn: UILabel!
    @IBOutlet weak var tagContainer: UIView!
    @IBOutlet weak var lbDetailInfo: UILabel!
    
    var passData:JSON!
    var data:JSON!
    var tagsField = WSTagsField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        let title = passData["name"].stringValue
        CNavigationBar.drawTitle(self, title)
        
        safetyView.isHidden = !isEdgePhone
        self.decorationUi()
        self.requestProductDetail()
    }
    
    func requestProductDetail() {
        var param = [String:Any]()
        param["product_no"] = passData["product_no"].stringValue
        param["user_no"] = ShareData.ins.userNo
        param["kind"] = ShareData.ins.kind.rawValue
        
        ApiManager.ins.requestProductDetail(param: param) { res in
            self.data = res["data"]
            self.decorationUi()
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    func decorationUi() {
        guard let data = data,  data.isEmpty == false else {
            lbName.text = ""
            lbProductKind.text = ""
            btnLikeCount.setTitle("0", for: .normal)
            btnViews.setTitle("", for: .normal)
            lbPrice.text = "0"
            
            lbColor.text = ""
            lbSize.text = ""
            lbMaterial.text = ""
            lbCountry.text = ""
            lbPieceYn.text = ""
            lbDetailInfo.text = ""
            
            return
        }
        
        let img_list = data["img_list"].arrayValue
        if img_list.isEmpty == false {
            svImg.subviews.forEach { sub in
                sub.removeFromSuperview()
            }
            for img in img_list {
                let iv = UIImageView.init()
                iv.contentMode = .scaleAspectFill
                svImg.addArrangedSubview(iv)
                iv.translatesAutoresizingMaskIntoConstraints = false
                iv.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0).isActive = true
                iv.setImageCache(img.stringValue)
            }
        }
        
        lbName.text = data["name"].stringValue
        lbProductKind.text = data["category"].stringValue
        
        let like = data["like"].numberValue
        btnLikeCount.setTitle(like.toString(), for: .normal)
        
        let views = data["views"].numberValue
        btnViews.setTitle(views.toString(), for: .normal)
        
        let price = data["price"].numberValue
        lbPrice.text = price.toString()
        
        
        let option = data["option"]
        let color = option["color"].stringValue
        let sheetYN = option["sheetYN"].stringValue
        let size = option["size"].stringValue
        let country = option["country"].stringValue
        let fabric = option["fabric"].stringValue
        let dispYN = option["dispYN"].stringValue
        
        lbColor.text = color
        lbSize.text = size
        lbMaterial.text = fabric
        lbCountry.text = country
        lbPieceYn.text = sheetYN
        
        btnSoldoutStatus.isHidden = true
        if dispYN == "soldout" {
            btnSoldoutStatus.isHidden = false
        }
        
        let ai_tag = data["ai_tag"].arrayValue
        for subview in tagContainer.subviews {
            subview.removeFromSuperview()
        }
        
        self.tagContainer.addSubview(tagsField)
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: tagContainer.topAnchor),
            tagsField.leadingAnchor.constraint(equalTo: tagContainer.leadingAnchor, constant: 0),
            tagsField.trailingAnchor.constraint(equalTo: tagContainer.trailingAnchor, constant: 0),
            tagsField.bottomAnchor.constraint(equalTo: tagContainer.bottomAnchor)
        ])
        
        tagsField.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        tagsField.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) //old padding
        tagsField.cornerRadius = 16.0
        tagsField.spaceBetweenLines = 12
        tagsField.spaceBetweenTags = 8
        tagsField.tintColor = .clear
        tagsField.textColor = UIColor.label
        tagsField.borderWidth = 1
        tagsField.borderColor = UIColor(named: "BorderColor")
        tagsField.textField.textColor =  UIColor.label
        tagsField.font = UIFont.systemFont(ofSize: 13)
        tagsField.readOnly = true
        
        for item in ai_tag {
            let title = item["value"].stringValue
            if title.isEmpty == false {
                tagsField.addTag(title)
            }
        }
        
        lbDetailInfo.text = data["info"].stringValue
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnModify {
            let naviCtrl = self.navigationController
            self.navigationController?.popViewController(animated: false)
            
            let vc = WProductModifyViewController.instantiateFromStoryboard(.wsale)!
            vc.passData = data
            naviCtrl?.pushViewController(vc, animated: true)
        }
        else if sender == btnSoldout {
            var param = [String:Any]()
            param["comp_no"] = ShareData.ins.compNo
            param["product_no"] = data["product_no"].intValue
           
            ApiManager.ins.requestProductSoldout(param) { res in
                if res["success"].boolValue {
                    appDelegate.window?.makeToast("품절 처리되었습니다.")
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnDel {
            CAlertViewController.show(type: .alert, message: "상품을 삭제하시겠습니까?\n삭제 시 복구할 수 없습니다.", actions:[.cancel, .ok]) { vcs, action in
                vcs.dismiss(animated: true, completion: nil)
                if action == 1 {
                    var param = [String:Any]()
                    param["user_no"] = ShareData.ins.userNo
                    param["comp_no"] = ShareData.ins.compNo
                    param["product_no"] = self.data["product_no"].intValue
                    
                    ApiManager.ins.requestDeleteProductInfo(param) { res in
                        if res["success"].boolValue {
                            self.navigationController?.popViewController(animated: true)
                        }
                        else {
                            self.showErrorToast(res)
                        }
                    } fail: { error in
                        self.showErrorToast(error)
                    }
                }
            }
        }
    }
}
