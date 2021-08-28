//
//  FtAmountViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/10.
//

import UIKit
import SwiftyJSON

class FtAmountViewController: BaseViewController {
    @IBOutlet weak var btnSave: CButton!
    @IBOutlet weak var btnReset: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    @IBOutlet weak var tfMin: UITextField!
    @IBOutlet weak var tfMax: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "FilterColCell", bundle: nil), forCellWithReuseIdentifier: "FilterColCell")
        }
    }
    
    var configData:[JSON]?
    var listData:[JSON]!
    var completion:((_ item:Any?, _ action:Int) ->Void)?
    
    var selIndexPath:IndexPath?
    var selTabMenu: Int = 0
    var toolbar = CToolbar.init(barItems: [.keyboardDown])
    static func initWithData(_ data:[JSON], _ configData:[JSON]?, completion:((_ item: Any?, _ action:Int) ->Void)?) -> FtAmountViewController {
        let vc = FtAmountViewController.instantiateFromStoryboard(.common)!
        vc.completion = completion
        vc.configData = configData
        vc.listData = data
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
        
        tfMin.inputAccessoryView = toolbar
        tfMax.inputAccessoryView = toolbar
        toolbar.addTarget(self, selctor: #selector(actionKeybardDown))
     
        let attrN = NSAttributedString.init(string: "가격 초기화", attributes: [.foregroundColor:RGB(160, 160, 160), .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        let attrS = NSAttributedString.init(string: "가격 초기화", attributes: [.foregroundColor:UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        
        btnReset.setAttributedTitle(attrN, for: .normal)
        btnReset.setAttributedTitle(attrS, for: .selected)
        btnReset.setBackgroundImage(UIImage.color(from: RGB(233, 233, 233)), for: .normal)
        btnReset.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .selected)
        
        safetyView.isHidden = !isEdgePhone
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    func reloadData() {
        selIndexPath = nil
        btnReset.isSelected = false
        collectionView.reloadData()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSave {
            self.view.endEditing(true)
            if let listData = listData, let selIndexPath = selIndexPath {
                let item = listData[selIndexPath.row]
                self.completion?(item, 1)
            }
            else if let min = tfMin.text, min.isEmpty == false, let max = tfMax.text, max.isEmpty == false, let minP = Int(min), let maxP = Int(max) {
                let item:JSON = JSON(["title": "\(minP)~\(maxP)", "min":minP, "max":maxP, "code": 5])
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

extension FtAmountViewController: UICollectionViewDataSource, UICollectionViewDelegate, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterColCell", for: indexPath) as? FilterColCell else {
            return UICollectionViewCell()
        }
        
        let item = listData[indexPath.row]
        cell.btnTitle.setTitle(item["title"].stringValue, for: .normal)
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
            btnReset.isSelected = false
        }
        else {
            self.selIndexPath = indexPath
            btnReset.isSelected = true
        }
        self.collectionView.reloadData()
        let item = listData[indexPath.row]
        tfMin.text = nil
        tfMax.text = nil
        self.view.endEditing(true)
        self.completion?(item, 3)
    }
}

extension FtAmountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfMin {
            tfMax.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in:text) else {
            return false
        }
        let newText = text.replacingCharacters(in: textRange, with: string)
        if textField == tfMin {
            if let tmpTxt = tfMax.text, tmpTxt.isEmpty == false, newText.isEmpty == false {
                selIndexPath = nil
                btnReset.isSelected = true
                collectionView.reloadData()
            }
            else if let selIndexPath = selIndexPath, selIndexPath.isEmpty == false {
                btnReset.isSelected = true
            }
            else {
                btnReset.isSelected = false
            }
        }
        else if textField == tfMax {
            if let tmpTxt = tfMin.text, tmpTxt.isEmpty == false, newText.isEmpty == false {
                selIndexPath = nil
                btnReset.isSelected = true
                collectionView.reloadData()
            }
            else if let selIndexPath = selIndexPath, selIndexPath.isEmpty == false {
                btnReset.isSelected = true
            }
            else {
                btnReset.isSelected = false
            }
        }
        return true
    }
    
}
