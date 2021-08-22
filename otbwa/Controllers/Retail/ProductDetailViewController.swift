//
//  ProductDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON
import WSTagsField

class ProductDetailViewController: BaseViewController {
    @IBOutlet weak var btnOrder: CButton!
    @IBOutlet weak var btnLike: CButton!
    @IBOutlet weak var btnUpDown: UIButton!
    @IBOutlet weak var svBottomContainer: UIStackView!
    @IBOutlet weak var safetyView: UIView!
    
    //scrollView
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbProductKind: UILabel!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnViews: UIButton!
    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var btnAddress: CButton!
    @IBOutlet weak var lbColor: UILabel!
    @IBOutlet weak var lbSize: UILabel!
    @IBOutlet weak var lbMaterial: UILabel!
    @IBOutlet weak var lbCountry: UILabel!
    @IBOutlet weak var lbPieceYn: UILabel!
    @IBOutlet weak var tagContainer: UIView!
    @IBOutlet weak var lbDetailInfo: UILabel!
    
    @IBOutlet weak var svSimularProduct: UIStackView!
    @IBOutlet weak var colViewSimular: UICollectionView! {
        didSet {
            colViewSimular.register(UINib(nibName: "ProductColCell", bundle: nil), forCellWithReuseIdentifier: "ProductColCell")
        }
    }
    @IBOutlet weak var svMatchProduct: UIStackView!
    @IBOutlet weak var colViewMatch: UICollectionView! {
        didSet {
            colViewMatch.register(UINib(nibName: "ProductColCell", bundle: nil), forCellWithReuseIdentifier: "ProductColCell")
        }
    }
    
    var tagsField = WSTagsField()
    var orderSelectionView: OrderSelectionView!
    var passData:JSON!
    var data:JSON = JSON()
    var similar = [JSON]()
    var matching = [JSON]()
    
    var options: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = passData["name"].stringValue
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, title, nil)
        
        orderSelectionView = Bundle.main.loadNibNamed("OrderSelectionView", owner: nil, options: nil)?.first as? OrderSelectionView
        orderSelectionView.layer.cornerRadius = 20
        orderSelectionView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        svBottomContainer.insertArrangedSubview(orderSelectionView, at: 0)
        orderSelectionView.isHidden = true
        safetyView.isHidden = !Utility.isEdgePhone()
        
        self.initUI()
        self.requestProductDetail()
        self.requestRecommendProducts()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    func initUI() {
        self.view.layoutIfNeeded()
        
        lbName.text = ""
        lbProductKind.text = ""
        lbPrice.text = ""
        if let lbAddr = btnAddress.viewWithTag(100) as? UILabel {
            lbAddr.text = ""
        }
        lbColor.text = ""
        lbSize.text = ""
        lbMaterial.text = ""
        lbCountry.text = ""
        lbPieceYn.text = ""
        lbDetailInfo.text = ""
    }
    func requestProductDetail() {
        var param = [String:Any]()
        param["kind"] = ShareData.ins.kind.rawValue
        param["user_no"] = ShareData.ins.userNo
        param["product_no"] = passData["product_no"].numberValue
        ApiManager.ins.requestProductDetail(param:param) { res in
            let success = res["success"].boolValue
            if success {
                self.data = res["data"]
                self.decorationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func requestRecommendProducts() {
        let productNo = passData["product_no"].stringValue
        ApiManager.ins.requestRecommendProducts(productNo: productNo) { res in
            let success = res["success"].boolValue
            if success {
                self.similar = res["data"]["similar"].arrayValue
                self.matching = res["data"]["matching"].arrayValue
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
        let img = passData["img"].stringValue
        if img.isEmpty == false {
            ivThumb.setImageCache(img)
        }
        
        if data.isEmpty == false {
            lbName.text = data["name"].stringValue
            lbProductKind.text = data["category"].stringValue
            let like = data["like"].numberValue
            btnLikeCount.setTitle(like.toString(), for: .normal)
            
            let views = data["views"].numberValue
            btnViews.setTitle(views.toString(), for: .normal)
            
            let addr = data["addr"].stringValue
            if let lbAddr = btnAddress.viewWithTag(100) as? UILabel {
                lbAddr.text = addr
            }
            
            let like_yn = data["like_yn"].stringValue
            btnLike.isSelected = (like_yn == "Y")
            
            let option = data["option"]
            let color = option["color"].stringValue
//            let matchingYN = option["matchingYN"].stringValue
//            let style = option["style"].stringValue
//            let dispYN = option["dispYN"].stringValue
            let sheetYN = option["sheetYN"].stringValue
            let size = option["size"].stringValue
            let country = option["country"].stringValue
            
            lbColor.text = color
            lbSize.text = size
            lbMaterial.text = ""
            lbCountry.text = country
            lbPieceYn.text = sheetYN
            
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
        
            let colorArr = option["color"].stringValue.components(separatedBy: ",")
            let sizesArr = option["size"].stringValue.components(separatedBy: ",")
            if let cacheFilter = UserDefaults.standard.object(forKey: Dfskey.filterCacheData) as? [String:Any],
               let data = cacheFilter["data"] as? [String:Any], let color = data["color"] as? [[String:Any]],
               colorArr.isEmpty == false, sizesArr.isEmpty == false {
                
                let colorList:JSON = JSON(color)
                var colors = [JSON]()
                for name in colorArr {
                    let trimmedString = name.trimmingCharacters(in: .whitespaces)
                    for item in colorList.arrayValue {
                        if trimmedString == item["value"].stringValue {
                            colors.append(item)
                        }
                    }
                }
                
                var sizes = [JSON]()
                for name in sizesArr {
                    let trimmedString = name.trimmingCharacters(in: .whitespaces)
                    sizes.append(JSON(trimmedString))
                }
                orderSelectionView.configurationData(colors, sizes)
                orderSelectionView.completion = {(options:[JSON]?) ->Void in
                    self.options = options
                }
            }
        }
        
        svSimularProduct.isHidden = true
        if similar.isEmpty == false {
            svSimularProduct.isHidden = false
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.scrollDirection = .horizontal
            
            colViewSimular.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
            colViewSimular.collectionViewLayout = layout
            colViewSimular.reloadData()
        }
        
        svMatchProduct.isHidden = true
        if matching.isEmpty == false {
            svMatchProduct.isHidden = false
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.scrollDirection = .horizontal
            
            colViewMatch.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
            colViewMatch.collectionViewLayout = layout
            colViewMatch.reloadData()
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnUpDown {
            sender.isSelected = !sender.isSelected
            orderSelectionView.isHidden = !sender.isSelected
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
            } completion: { finish in
                
            }
            
            if sender.isSelected {
                btnOrder.setTitle("장바구니 담기", for: .normal)
                btnOrder.isSelected = true
            }
            else {
                btnOrder.setTitle("주문하기", for: .normal)
                btnOrder.isSelected = false
            }
        }
        else if sender == btnOrder {
            if sender.isSelected == false {
                sender.setTitle("장바구니 담기", for: .normal)
                btnUpDown.isSelected = true
                sender.isSelected = true
                
                orderSelectionView.isHidden = false
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                } completion: { finish in
                    
                }
            }
            else {
                guard let options = options, options.isEmpty == false else {
                    self.showToast("주문 옵션을 선택해주세요.", 80)
                    return
                }
                print(options)
                
                var ops = [[String:Any]]()
                for op in options {
                    var item = [String:Any]()
                    item["color"] = op["color_code"].stringValue
                    item["size"] = op["size"].stringValue
                    item["cnt"] = op["cnt"].intValue
                    ops.append(item)
                }
                var param = [String:Any]()
                param["product_option"] = ops
                param["product_no"] = data["product_no"].intValue
                param["user_no"] = ShareData.ins.userNo
                ApiManager.ins.requestProductPutBasket(param: param) { res in
                    let success = res["success"].boolValue
                    if success {
                        self.showToast("장바구니에 추가되었습니다.", 80)
                        self.btnOrder.setTitle("주문하기", for: .normal)
                        self.btnOrder.isSelected = false
                        self.btnUpDown.isSelected = false
                        self.orderSelectionView.isHidden = true
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { error in
                    self.showErrorToast(error)
                }
            }
        }
        else if sender == btnLike {
            if btnLike.isSelected {
                let param:[String:Any] = ["list":[data["product_no"].intValue], "user_no": ShareData.ins.userNo]
                ApiManager.ins.requestDeleteMyLikes(param: param) { res in
                    if res["success"].boolValue {
                        self.requestProductDetail()
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { error in
                    self.showErrorToast(error)
                }
            }
            else {
                //추가
                let param = ["product_no" : data["product_no"].intValue, "user_no" : ShareData.ins.userNo]
                ApiManager.ins.requestProductLike(param: param) { res in
                    if res["success"].boolValue {
                        self.requestProductDetail()
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { error in
                    self.showErrorToast(error)
                }
            }
        }
        else if sender == btnSearch {
            if let images = data["img_list"].arrayObject as? [String] {
                self.showPhoto(imgUrls: images)
            }
        }
        else if sender == btnAddress {
            let vc = StoreInfoViewController.instantiateFromStoryboard(.main)!
            vc.passData = self.data
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension ProductDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == colViewSimular {
            return similar.count
        }
        else {
            return matching.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductColCell", for: indexPath) as? ProductColCell else {
            return UICollectionViewCell()
        }
        if collectionView == colViewSimular {
            let item = similar[indexPath.section]
            cell.configurationData(item)
        }
        else {
            let item = matching[indexPath.section]
            cell.configurationData(item)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 180)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if collectionView == colViewSimular {
            let item = similar[indexPath.section]
            
            guard let navigationCtrl = self.navigationController else {
                return
            }
            navigationCtrl.popViewController(animated: false)
            let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
            vc.passData = item
            navigationCtrl.pushViewController(vc, animated: true)
        }
        else {
            let item = similar[indexPath.section]
            guard let navigationCtrl = self.navigationController else {
                return
            }
            navigationCtrl.popViewController(animated: false)
            let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
            vc.passData = item
            navigationCtrl.pushViewController(vc, animated: true)
        }
    }
}
