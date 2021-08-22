//
//  SearchTextViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/20.
//

import UIKit
import SwiftyJSON


class SearchTextViewController: BaseViewController {
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var tfSearch: CTextField!
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "SearchTextWholesaleColCell", bundle: nil), forCellWithReuseIdentifier: SearchTextWholesaleColCell.identifiler)
            collectionView.register(UINib(nibName: "ProductColCell", bundle: nil), forCellWithReuseIdentifier: ProductColCell.identifier)
            collectionView.register(UINib(nibName: "SearchTextResuableHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchTextResuableHeaderView.identifiler)
        }
    }
    
    var search: String?
    var page: Int = 1
    var isPageEnd = false
    var canRequest = true
    
    var listData = [Any]()
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 20, right: 18)
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self

        if let search = search {
            tfSearch.text = search
        }
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        self.dataReset()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func dataReset() {
        page = 1
        isPageEnd = false
        canRequest = true
        
        requestSearch()
    }
    func addData() {
        requestSearch()
    }
    func requestSearch() {
        guard let search = tfSearch.text, search.isEmpty == false else {
            return
        }
        if isPageEnd == true {
            return
        }
        var param = [String:Any]()
        param["search"] = search
        param["user_no"] = ShareData.ins.userNo
        param["p_current"] = page
        
        ApiManager.ins.requestProductSearch(param) { res in
            self.canRequest = true
            
            if res["success"].boolValue {
                let comp_list = res["data"]["comp_list"].arrayValue
                let product_list = res["data"]["product_list"].arrayValue
                
                if self.page == 1 {
                    self.listData.removeAll()
                    self.listData.append(comp_list)
                    self.listData.append(product_list)
                }
                else {
                    self.listData.append(comp_list)
                    self.listData.append(product_list)
                }
                self.collectionView.reloadData()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnBack {
            self.navigationController?.popViewController(animated: true)
        }
        else if sender == btnPhoto {
            let vc = PhotoSelectAlertViewController.initWithCompletion { souretype in
                self.checkPermissionPhoto(souretype)
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    override func displayImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        let vc = CImagePickerController.init(sourceType, false) { origin, crop in
            guard let image = origin else {
                return
            }
            
            if let findVc = self.navigationController?.viewControllers.filter({ vc ->Bool in
                return (vc is SearchTextViewController || vc is SearchImageViewController)
            }).first {
                self.navigationController?.popToViewController(findVc, animated: false)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                let vc = SearchImageViewController.instantiateFromStoryboard(.main)!
                vc.searchImg = image
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension SearchTextViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionList = listData[section] as? Array<JSON> {
            return sectionList.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchTextWholesaleColCell", for: indexPath) as? SearchTextWholesaleColCell else {
                return UICollectionViewCell()
            }
            if let sectionList = listData[indexPath.section] as? Array<JSON>, let item = sectionList[indexPath.row] as? JSON {
            
                let comp_addr = item["comp_addr"].stringValue
                let comp_nm = item["comp_nm"].stringValue
                let comp_no = item["comp_no"].numberValue
                
                cell.lbTitle.text = comp_nm
                cell.lbSubTitle.text = comp_addr
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductColCell", for: indexPath) as? ProductColCell else {
                return UICollectionViewCell()
            }
            
            if let sectionList = listData[indexPath.section] as? Array<JSON>, let item = sectionList[indexPath.row] as? JSON {
                cell.configurationData(item)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return .init(width: collectionView.bounds.size.width - 36, height: 64)
        }
        else {
            let width = (collectionView.bounds.size.width - 36 - 8)/2
            //166:260 = width: h
            let height = (240*width)/166
            return .init(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchTextResuableHeaderView", for: indexPath) as? SearchTextResuableHeaderView else {
                return UICollectionReusableView()
            }
            
            if indexPath.section == 0 {
                header.lbTitle.text = "도매"
            }
            else {
                header.lbTitle.text = "상품"
            }
            return header
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.size.width, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if let sectionList = listData[indexPath.section] as? Array<JSON>, let item = sectionList[indexPath.row] as? JSON {
                let vc = StoreInfoViewController.instantiateFromStoryboard(.main)!
                vc.passData = item
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if let sectionList = listData[indexPath.section] as? Array<JSON>, let item = sectionList[indexPath.row] as? JSON {
                
                let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
                vc.passData = item
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension SearchTextViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isEmpty == false else {
            return false
        }
        self.dataReset()
        return true
    }
}
