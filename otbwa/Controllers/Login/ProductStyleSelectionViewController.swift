//
//  ProductStyleSelectionViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/02.
//

import UIKit
import SwiftyJSON

class ImageSelectedColCell: UICollectionViewCell {
    static var identifier = "ImageSelectedColCell"
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var btnSelection: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSelection.layer.cornerRadius = 6
        ivThumb.layer.cornerRadius = 6
    }
}

class ProductStyleSelectionViewController: BaseViewController {
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user:UserInfo = UserInfo()
    var selIndexPaths = [IndexPath]()
    var listData = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "소매 회원가입", nil)
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        safetyView.isHidden = !isEdgePhone
        
        collectionView.isMultipleTouchEnabled = true
        
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 3
        layout.delegate = self
        layout.lineSpacing = 8
        layout.secInset = UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)
        collectionView.collectionViewLayout = layout
        self.requestStyleImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func requestStyleImages() {
        ApiManager.ins.requestStyleImages { res in
            let success = res["success"].boolValue
            if success {
                self.listData = res["data"]["list"].arrayValue
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
        if sender == btnNext {
        
            if selIndexPaths.count > 0 {
                var imgs = "["
                for i in 0..<selIndexPaths.count {
                    let indexPath = selIndexPaths[i]
                    let item = listData[indexPath.row]
                    let img_no = item["img_no"]
                    if i < (selIndexPaths.count-1) {
                        imgs.append("\(img_no),")
                    }
                    else {
                        imgs.append("\(img_no)")
                    }
                }
                imgs.append("]")
                user.selected_img = imgs
                print(user.selected_img!)
            }
            
            let vc = StoreInofViewController2.instantiateFromStoryboard(.login)!
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ProductStyleSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSelectedColCell.identifier, for: indexPath) as? ImageSelectedColCell else {
            return UICollectionViewCell()
        }
        let item = listData[indexPath.row]
        let img = item["img"].stringValue
        cell.ivThumb.setImageCache(img)
        
        if selIndexPaths.contains(indexPath) == true {
            cell.btnSelection.backgroundColor = RGBA(225, 111, 72, 0.2)
            cell.btnSelection.layer.borderWidth = 3
            cell.btnSelection.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        }
        else {
            cell.btnSelection.backgroundColor = UIColor.clear
            cell.btnSelection.layer.borderWidth = 0
            cell.btnSelection.layer.borderColor = nil
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        let height = round(1.0 * (Float(collectionView.bounds.size.width - 36)/3.0))
        return CGFloat(height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = selIndexPaths.firstIndex(of: indexPath) {
            selIndexPaths.remove(at: index)
        }
        else {
            selIndexPaths.append(indexPath)
        }
        self.collectionView.reloadData()
    }
}
