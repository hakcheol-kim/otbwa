//
//  FtColorViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/10.
//

import UIKit
import SwiftyJSON

class FtColorViewController: BaseViewController {
    @IBOutlet weak var btnSave: CButton!
    @IBOutlet weak var btnReset: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "FilterColorColCell", bundle: nil), forCellWithReuseIdentifier: "FilterColorColCell")
        }
    }
    
    var configData:[JSON]?
    var data:[JSON]!
    var completion:((_ item:Any?, _ action: Int) ->Void)?
    
    var selIndexPaths = [IndexPath]()
    
    static func initWithData(_ data:[JSON], _ configData:[JSON]?, completion:((_ item: Any?, _ action:Int) ->Void)?) -> FtColorViewController {
        let vc = FtColorViewController.instantiateFromStoryboard(.common)!
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
        
        
        let attrN = NSAttributedString.init(string: "색상 초기화", attributes: [.foregroundColor:RGB(160, 160, 160), .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        let attrS = NSAttributedString.init(string: "색상 초기화", attributes: [.foregroundColor:UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        
        btnReset.setAttributedTitle(attrN, for: .normal)
        btnReset.setAttributedTitle(attrS, for: .selected)
        btnReset.setBackgroundImage(UIImage.color(from: RGB(233, 233, 233)), for: .normal)
        btnReset.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .selected)
        
        safetyView.isHidden = !isEdgePhone
    }
    
    func reloadData() {
        self.selIndexPaths.removeAll()
        self.btnReset.isSelected = false
        self.collectionView.reloadData()
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSave {
            var selColors: [JSON]? = nil
            if selIndexPaths.isEmpty == false {
                selColors = [JSON]()
                for index in selIndexPaths {
                    let item = data[index.row]
                    selColors!.append(item)
                }
            }
            self.completion?(selColors, 1)
        }
        else if sender == btnReset {
            self.reloadData()
            self.completion?(nil, 2)
        }
    }

}

extension FtColorViewController: UICollectionViewDataSource, UICollectionViewDelegate, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterColorColCell", for: indexPath) as? FilterColorColCell else {
            return UICollectionViewCell()
        }
        
        let item = data[indexPath.row]
        if selIndexPaths.contains(indexPath) == true {
            cell.configurationData(item, true)
        }
        else {
            cell.configurationData(item, false)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        return 48
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = selIndexPaths.firstIndex(of: indexPath) {
            selIndexPaths.remove(at: index)
        }
        else {
            selIndexPaths.append(indexPath)
        }
        self.collectionView.reloadData()
        
        var selColors: [JSON]? = nil
        if selIndexPaths.isEmpty == false {
            selColors = [JSON]()
            for index in selIndexPaths {
                let item = data[index.row]
                selColors!.append(item)
            }
        }
        if selIndexPaths.isEmpty == false {
            btnReset.isSelected = true
        }
        else {
            btnReset.isSelected = false
        }
        
        self.completion?(selColors, 3)
    }
}
