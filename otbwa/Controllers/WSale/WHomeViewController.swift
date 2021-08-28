//
//  WHomeViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON

class WHomeViewController: BaseViewController {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var btnSpeaker: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearchIcon: UIButton!
    @IBOutlet weak var btnSort: CButton!
    @IBOutlet weak var tfSort: UITextField!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnProdManagement: UIButton!
    @IBOutlet weak var btnShowManagement: UIButton!
    @IBOutlet weak var editingView: ShadowView!
    @IBOutlet weak var btnSoldOut: CButton!
    @IBOutlet weak var btnRestock: CButton!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "WProductColCell", bundle: nil), forCellWithReuseIdentifier: "WProductColCell")
        }
    }
    
    var listData = [JSON]()
    var selIndexPaths = [IndexPath]()
    
    var page = 1
    var canRequest = true
    var isPageEnd = false
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    
    let orderTypes = [["code":"latest", "title":"최신상품순"], ["code":"like", "title":"찜 카운트 최다 순"]]
    
    var selOrderType:[String:Any]! {
        didSet {
            let title = selOrderType["title"] as? String
            tfSort.text = title
        }
    }
    var listType: ListType = .normal {
        didSet {
            editingView.isHidden = !(listType == .editing)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CFlowLayout.init()
        layout.secInset = UIEdgeInsets(top: 4, left: 18, bottom: 4, right: 18)
        layout.lineSpacing = 8
        layout.numberOfColumns = 3
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        
        lbName.text = ShareData.ins.compNm
        
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        self.selOrderType = orderTypes.first
        editingView.isHidden = !btnShowManagement.isSelected
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataReset()
    }
    
    func dataReset() {
        self.page = 1
        self.canRequest = true
        self.isPageEnd = false
        self.requestProductSearch()
        
    }
    func addData() {
        self.requestProductSearch()
    }
    
    func requestProductSearch() {
        if isPageEnd == true || canRequest == false {
            return
        }
        
        self.canRequest = false
        
        var param = [String:Any]()
        param["comp_no"] = ShareData.ins.compNo
        
        param["disp"] = "all"
        if btnCheck.isSelected {
            param["disp"] = "client"
        }
        param["kind"] = ShareData.ins.kind.rawValue
        param["order_type"] = selOrderType["code"]
        if let search = tfSearch.text, search.isEmpty == false {
            param["search"] = search
        }
        param["p_current"] = page
        
        
        ApiManager.ins.requestCompProductSearch(param) { res in
            self.canRequest = true
            if res["success"].boolValue {
                let list = res["data"]["list"].arrayValue
                
                if list.isEmpty == true {
                    self.isPageEnd = true
                }
                if self.page == 1 {
                    self.listData = list
                }
                else {
                    self.listData.append(contentsOf: list)
                }
                self.page += 1
                self.collectionView.reloadData()
            }
            else {
                
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSort {
            let vc = PopupListViewController.initWithType(.normal, nil, orderTypes, ["title"]) { vcs, item, action in
                guard let item = item as? [String:Any] else {
                    return
                }
                self.selOrderType = item
                
                vcs.dismiss(animated: true, completion: nil)
            }
            self.presentPanModal(vc)
        }
        else if sender == btnCheck {
            sender.isSelected = !sender.isSelected
            self.dataReset()
        }
        else if sender == btnSearchIcon {
            tfSearch.becomeFirstResponder()
        }
        else if sender == btnSpeaker {
            
        }
        else if sender == btnProdManagement {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                listType = .editing
            }
            else {
                listType = .normal
            }
            self.collectionView.reloadData()
        }
        else if sender == btnShowManagement {
            
        }
        else if sender == btnSoldOut {
            self.requestProductStatus("soldout")
        }
        else if sender == btnRestock {
            self.requestProductStatus("restock")
        }
    }
    
    func requestProductStatus(_ status:String) {
        guard selIndexPaths.isEmpty == false else {
            return
        }
        var selList = [JSON]()
        for indexPath in selIndexPaths {
            selList.append(listData[indexPath.row])
        }
        var reqCnt = 0
        for item in selList {
            var param = [String:Any]()
            param["comp_no"] = ShareData.ins.compNo
            param["disp"] = "all"
            if btnCheck.isSelected {
                param["disp"] = "client"
            }
            param["order_type"] = selOrderType["code"]
            param["product_no"] = item["product_no"].intValue
            param["status"] = status
            
            ApiManager.ins.requestChangeProductStatus(param) { res in
                if reqCnt == (selList.count - 1) {
                    self.dataReset()
                    self.listType = .normal
                }
                reqCnt += 1
            } fail: { errr in
                
            }
        }
    }
}

extension WHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WProductColCell", for: indexPath) as? WProductColCell else {
            return UICollectionViewCell()
        }
        
        let item = listData[indexPath.row]
        
        if selIndexPaths.contains(indexPath) == true {
            cell.configurationData(item, listType, true)
        }
        else {
            cell.configurationData(item, listType, false)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        let width = (collectionView.bounds.width - 36 - 16)/3
        //108:220 = w:h
        let h = (190*width)/108
        return h
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            self.addData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if listType == .editing {
            if let index = selIndexPaths.firstIndex(of: indexPath) {
                selIndexPaths.remove(at: index)
            }
            else {
                selIndexPaths.append(indexPath)
            }
            
            self.collectionView.reloadData()
        }
        else {
            let item = listData[indexPath.row]
            let vc = WProductDetailViewController.instantiateFromStoryboard(.wsale)!
            vc.passData = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension WHomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.dataReset()
        return true
    }
}
