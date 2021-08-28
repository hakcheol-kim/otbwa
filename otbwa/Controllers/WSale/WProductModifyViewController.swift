//
//  WProductModifyViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/27.
//

import UIKit
import SwiftyJSON

class WProductModifyViewController: BaseViewController {
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var tfCategory: CTextField!
    @IBOutlet weak var tfProdName: CTextField!
    @IBOutlet weak var tfProdPrice: CTextField!
    
    ///
    @IBOutlet weak var imgBgView: CView!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var svImgContent: UIStackView!
    @IBOutlet weak var btnAddPhoto: CButton!
    @IBOutlet weak var btnSearch: CButton!
    
    @IBOutlet weak var svAiTags: UIStackView!
    @IBOutlet weak var tfColor: CTextField!
    @IBOutlet weak var tfSize: CTextField!
    @IBOutlet weak var tvMemo: CTextView!
    
    @IBOutlet weak var btnAiMatchingOn: SelectedButton!
    @IBOutlet weak var btnAiMatchingOff: SelectedButton!
    
    @IBOutlet weak var btnCountryKr: SelectedButton!
    @IBOutlet weak var btnCountryCn: SelectedButton!
    @IBOutlet weak var btnCountryOther: SelectedButton!
    
    @IBOutlet weak var btnPieceOn: SelectedButton!
    @IBOutlet weak var btnPieceOff: SelectedButton!
    
    @IBOutlet weak var btnAll: SelectedButton!
    @IBOutlet weak var btnClient: SelectedButton!
    @IBOutlet weak var btnSoldOut: SelectedButton!
    
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var passData: JSON!
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "상품 관리")
        
        tfCategory.inputAccessoryView = toolBar
        tfProdName.inputAccessoryView = toolBar
        tfProdPrice.inputAccessoryView = toolBar
        tfColor.inputAccessoryView = toolBar
        tfSize.inputAccessoryView = toolBar
        tvMemo.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        
        self.addKeyboardNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    func configuratinUi() {
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
}
extension WProductModifyViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfCategory {
            let vc = HashTagViewController.initWithType(.hastagOne) { items in
                guard let tags = items as? [JSON] else {
                    return
                }
            }
            self.present(vc, animated: true, completion: nil)
         
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension WProductModifyViewController: UITextViewDelegate {
    
}
extension WProductModifyViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y > 0) {
            UIView.animate(withDuration: 0.2, delay: 0, options:.curveEaseInOut, animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                print("Hide")
            }, completion: nil)
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                print("Unhide")
            }, completion: nil)
        }
    }
}
