//
//  FtCountyViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/10.
//

import UIKit
import SwiftyJSON

class FtCountyViewController: BaseViewController {
    @IBOutlet weak var btnSave: CButton!
    @IBOutlet weak var btnReset: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "FilterColCell", bundle: nil), forCellWithReuseIdentifier: "FilterColCell")
        }
    }
    var configData:[JSON]?
    var listData:[JSON]!
    var completion:((_ item:Any?, _ action:Int) ->Void)?
    var selIndexPath:IndexPath?
    
    static func initWithData(_ data:[JSON], _ configData:[JSON]?, completion:((_ item: Any?, _ action:Int) ->Void)?) -> FtCountyViewController {
        let vc = FtCountyViewController.instantiateFromStoryboard(.common)!
        vc.completion = completion
        vc.listData = data
        vc.configData = configData
        
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CFlowLayout.init()
        layout.secInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        layout.lineSpacing = 10
        layout.numberOfColumns = 3
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        
        
        let attrN = NSAttributedString.init(string: "제조국 초기화", attributes: [.foregroundColor:RGB(160, 160, 160), .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        let attrS = NSAttributedString.init(string: "제조국 초기화", attributes: [.foregroundColor:UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        
        btnReset.setAttributedTitle(attrN, for: .normal)
        btnReset.setAttributedTitle(attrS, for: .selected)
        btnReset.setBackgroundImage(UIImage.color(from: RGB(233, 233, 233)), for: .normal)
        btnReset.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .selected)
        
        safetyView.isHidden = !Utility.isEdgePhone()
    }
    
    func reloadData() {
        selIndexPath = nil
        btnReset.isSelected = false
        collectionView.reloadData()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSave {
            if let listData = listData, let selIndexPath = selIndexPath {
                let item = listData[selIndexPath.row]
                self.completion?(item, 1)
            }
            else {
                self.completion?(nil, 1)
            }
        }
        else if sender == btnReset {
            self.reloadData()
            self.completion?(nil, 2)
        }
    }

    
}

extension FtCountyViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterColCell", for: indexPath) as? FilterColCell else {
            return UICollectionViewCell()
        }
        
        let item = listData[indexPath.row]
        cell.btnTitle.setTitle(item["value"].stringValue, for: .normal)
        cell.btnTitle.isSelected = false
        
        if let selIndexPath = selIndexPath, selIndexPath.row == indexPath.row {
            cell.btnTitle.isSelected = true
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        return 48
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selIndexPath = selIndexPath, selIndexPath.row == indexPath.row {
            self.selIndexPath = nil
            self.btnReset.isSelected = false
        }
        else {
            self.selIndexPath = indexPath
            self.btnReset.isSelected = true
        }
        self.collectionView.reloadData()
        let item = listData[indexPath.row]
        self.completion?(item, 3)
    }
}
