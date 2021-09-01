//
//  SearchImageViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/20.
//

import UIKit
import SwiftyJSON

class SearchImageViewController: BaseViewController {
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var tfSearch: CTextField!
    @IBOutlet weak var collectionVeiw: UICollectionView! {
        didSet {
            collectionVeiw.register(UINib(nibName: "SearchImageReusableHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchImageReusableHeaderView")
            collectionVeiw.register(UINib(nibName: "EmptyColCell", bundle: nil), forCellWithReuseIdentifier: "EmptyColCell")
            collectionVeiw.register(UINib(nibName: "ProductColCell", bundle: nil), forCellWithReuseIdentifier: "ProductColCell")
        }
    }
    var listData = [JSON]()
    var aiTags = [JSON]()
    var searchImg: UIImage?
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var header: SearchImageReusableHeaderView?
    
    var hideImageView = false
    var hideTagView = false
    var heightTagView:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 20, right: 18)
        collectionVeiw.collectionViewLayout = layout
        
        dataReset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnBack {
            self.navigationController?.popViewController(animated: true)
        }
        else if sender == btnPhoto {
            let vc = ImageSelectOptionViewController.initWithCompletion { vcs, sourceType in
                vcs?.dismiss(animated: true, completion: nil)
//                self.checkPermissionPhoto(sourceType)
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    func dataReset() {
        var param = [String:Any]()
        param["img"] = searchImg
        param["type"] = "img"
        ApiManager.ins.requestSearchAiImageTag(param) { res in
            if res["success"].boolValue {
                print(res)
                self.aiTags = res["data"]["map"].arrayValue
                self.listData = res["data"]["list"].arrayValue
                
                self.collectionVeiw.reloadData()
                self.collectionVeiw.reloadData(0.1) {
                    self.collectionVeiw.reloadData()
                }
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
//    override func displayImagePicker(_ sourceType: UIImagePickerController.SourceType) {
//        let vc = CImagePickerController.init(sourceType, false) { origin, crop in
//            guard let image = origin else {
//                return
//            }
//            self.searchImg = image
//            self.dataReset()
//        }
//        self.present(vc, animated: true, completion: nil)
//    }
    
    func gotoSearchTextVc(_ search: String) {
        if let findVc = self.navigationController?.viewControllers.filter({ vc ->Bool in
            return (vc is SearchTextViewController || vc is SearchImageViewController)
        }).first {
            self.navigationController?.popToViewController(findVc, animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            let vc = SearchTextViewController.instantiateFromStoryboard(.main)!
            vc.search = search
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
}

extension SearchImageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isEmpty == false else {
            return false
        }
        gotoSearchTextVc(text)
        return true
    }
}

extension SearchImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listData.isEmpty == true {
            return 1
        }
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if listData.isEmpty == true {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyColCell", for: indexPath) as? EmptyColCell else {
                return UICollectionViewCell()
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductColCell", for: indexPath) as? ProductColCell else {
                return UICollectionViewCell()
            }
            let item = listData[indexPath.row]
            cell.configurationData(item)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchImageReusableHeaderView", for: indexPath) as? SearchImageReusableHeaderView else {
                return UICollectionReusableView()
            }
            self.header = header
            header.configuratinData(searchImg, aiTags, hideImageView, hideTagView)
            header.completion = {(action, isSelected) ->Void in
                if action == 100 {
                    self.hideImageView = isSelected
                    self.collectionVeiw.reloadData()
                }
                else if action == 200 {
                    self.hideTagView = isSelected
                    self.collectionVeiw.reloadData()
                }
                else if action == 300 {
                    self.dataReset()
                }
            }
            return header
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if listData.isEmpty == true {
            return .init(width: collectionView.bounds.size.width - 36, height: 120)
        }
        else {
            let width = (collectionView.bounds.size.width - 36 - 8)/2
            //166:260 = width: h
            let height = (240*width)/166
            return .init(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var totalHeight:CGFloat = 0
        if hideImageView == false {
            totalHeight += collectionView.bounds.size.width*(320/375)
        }
        totalHeight += (22+32+30+24)// button height
        if hideTagView == false {
            totalHeight += CGFloat(Int(aiTags.count/3)*40)
        }
        
        return .init(width: collectionView.bounds.size.width, height: totalHeight)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard listData.isEmpty == false else {
            return
        }
        
        let item = listData[indexPath.row]
        let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
