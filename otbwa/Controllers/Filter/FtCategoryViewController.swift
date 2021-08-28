//
//  FtCategoryViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/10.
//

import UIKit
import SwiftyJSON
class FtCategoryViewController: BaseViewController {
    @IBOutlet weak var btnSave: CButton!
    @IBOutlet weak var btnReset: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    @IBOutlet weak var svMenu: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "FilterColCell", bundle: nil), forCellWithReuseIdentifier: "FilterColCell")
        }
    }
    
    var configData:[JSON]?
    var data:[JSON]!
    var completion:((_ item:Any?, _ action:Int) ->Void)?
    var listDta: [JSON]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var selIndexPath:IndexPath?
    var selTabMenu: Int = 0
    
    static func initWithData(_ data:[JSON], _ configData:[JSON]?, completion:((_ item: Any?, _ action:Int) ->Void)?) -> FtCategoryViewController {
        let vc = FtCategoryViewController.instantiateFromStoryboard(.common)!
        vc.completion = completion
        vc.configData = configData
        vc.data = data
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
        
        let attrN = NSAttributedString.init(string: "카테고리 초기화", attributes: [.foregroundColor:RGB(160, 160, 160), .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        let attrS = NSAttributedString.init(string: "카테고리 초기화", attributes: [.foregroundColor:UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        
        btnReset.setAttributedTitle(attrN, for: .normal)
        btnReset.setAttributedTitle(attrS, for: .selected)
        btnReset.setBackgroundImage(UIImage.color(from: RGB(233, 233, 233)), for: .normal)
        btnReset.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .selected)
        
        safetyView.isHidden = !isEdgePhone
        configurationMenu()
    }
    
    func configurationMenu() {
        
        let level2 = data.filter { (item) ->Bool in
            return item["level"].stringValue == "2"
        }
        
        for i in 0..<level2.count {
            let item = level2[i]
            let btn = CButton.init(type: .custom)
            let name = item["name"].stringValue
            
            let attrNor = NSAttributedString.init(string: name, attributes: [.foregroundColor: RGB(255, 197, 181), .font:UIFont.systemFont(ofSize: 13, weight: .regular)])
            
            let attrSel = NSAttributedString.init(string: name, attributes: [.foregroundColor: UIColor.white, .font:UIFont.systemFont(ofSize: 13, weight: .bold)])
            btn.setAttributedTitle(attrNor, for: .normal)
            btn.setAttributedTitle(attrSel, for: .selected)
            
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            btn.tag = 100+i
            svMenu.addArrangedSubview(btn)
            
            let level3 = data.filter { (tmp) -> Bool in
                return item["ctgr_id"].stringValue == tmp["up_ctgr_id"].stringValue
            }
            
            btn.data = level3
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        self.view.layoutIfNeeded()
        let btn = svMenu.subviews[selTabMenu] as? CButton
        btn?.sendActions(for: .touchUpInside)
    }
    func reloadData() {
        self.btnReset.isSelected = false
        self.selIndexPath = nil
        self.collectionView.reloadData()
    }
    @IBAction func onClickedBtnActions(_ sender: CButton) {
        if sender.tag >= 100 {
            for btn in svMenu.subviews {
                if let btn = btn as? CButton {
                    btn.isSelected = false
                }
                if let view = btn.viewWithTag(10) {
                    view.removeFromSuperview()
                }
            }
            
            sender.isSelected = true
            let underLine = UIView.init(frame: CGRect(x: 0, y: sender.frame.size.height-2, width: sender.bounds.width, height: 2))
            sender.addSubview(underLine)
            underLine.tag = 10
            underLine.backgroundColor = UIColor.white
            self.selIndexPath = nil
            self.listDta = sender.data as? [JSON]
            self.selTabMenu = sender.tag - 100
        }
        else if sender == btnSave {
            if let listData = listDta, let selIndexPath = selIndexPath {
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

extension FtCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDta?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterColCell", for: indexPath) as? FilterColCell else {
            return UICollectionViewCell()
        }
        
        if let listData = listDta {
            let item = listData[indexPath.row]
            cell.btnTitle.setTitle(item["name"].stringValue, for: .normal)
        }
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
        guard let listData = listDta else {
            return
        }
        let item = listData[indexPath.row]
        self.completion?(item, 3)
    }
}
