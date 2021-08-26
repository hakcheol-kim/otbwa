//
//  ModifyStoreInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON

class ModifyStoreInfoViewController: BaseViewController {
    @IBOutlet weak var btnSave: CButton!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var tfCeo: CTextField!
    @IBOutlet weak var tfStore: CTextField!
    @IBOutlet weak var tfPreStore: CTextField!
    @IBOutlet weak var tfCompNm: CTextField!
    
    @IBOutlet weak var tfTel: CTextField!
    @IBOutlet weak var btnPost: CButton!
    @IBOutlet weak var tfPostCode: CTextField!
    @IBOutlet weak var tfAddr: CTextField!
    @IBOutlet weak var tfDetailAddr: CTextField!
    @IBOutlet weak var tfFile: CTextField!
    @IBOutlet weak var btnFile: CButton!
    @IBOutlet weak var btnShowFile: CButton!
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var data: JSON!
    var file: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        safetyView.isHidden = !Utility.isEdgePhone()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "사업자정보 수정", nil)
        
        tfDetailAddr.inputAccessoryView = toolBar
        tfTel.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        self.addTapGestureKeyBoardDown()
        
        decorationUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    func decorationUI() {
        let representation = data["representation"].stringValue
        let comp_nm = data["comp_nm"].stringValue
        let comp_nm_scd = data["comp_nm_scd"].stringValue
        let comp_num = data["comp_num"].stringValue
        let tel = data["tel"].stringValue
        let addr = data["addr"].stringValue
        let comps = addr.components(separatedBy: " ")
        let detailAddr = comps.last
        var mainAddr = ""
        for i in 0..<comps.count-1 {
            mainAddr.append("\(comps[i]) ")
        }
        mainAddr.removeLast()
        
        tfCeo.text = representation
        tfStore.text = comp_nm
        tfPreStore.text = comp_nm_scd
        tfCompNm.text = comp_num
        
        tfAddr.text = mainAddr
        tfDetailAddr.text = detailAddr
        tfTel.text = tel
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPost {
            let vc = WkWebViewController.initWithUrl(urlAddrSearch, "주소검색") { data in
                guard let data = data as? [String : Any] else {
                    return
                }
                print(data)
                let json = JSON(data)
                if json["userSelectedType"].stringValue == "R" {
                    self.tfAddr.text = json["roadAddress"].stringValue
                }
                else {
                    self.tfAddr.text = json["jibunAddress"].stringValue
                }
                self.tfPostCode.text = json["zonecode"].stringValue
                self.tfDetailAddr.text = ""
                self.tfDetailAddr.becomeFirstResponder()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnFile {
            let vc = PhotoSelectAlertViewController.initWithCompletion { soureType in
                self.checkPermissionPhoto(soureType)
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if sender == btnShowFile {
            let vc = ImageShowViewController.instantiateFromStoryboard(.common)!
            vc.vcTitle = "사업자등록증"
            vc.url = data["img"].stringValue
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnSave {
            guard let addr = tfAddr.text, addr.isEmpty == false else {
                self.showToast("주소를 입력해주세요.")
                return
            }
            guard let tel = tfTel.text, tel.isEmpty == false else {
                self.showToast("전화번호를 입력해주세요.")
                return
            }
            guard tel.contains("-") == true else {
                self.showToast("전화번호 '-'를 포함한 값이어야 합니다.")
                return
            }
            
            var param = [String:Any]()
            var fullAddr = addr
            if let detailAddr = tfDetailAddr.text, detailAddr.isEmpty == false {
                fullAddr.append(" \(detailAddr)")
            }
            
            param["comp_addr"] = fullAddr
            param["comp_no"] = data["comp_num"].stringValue
            param["comp_tel"] = tel
            if let file = file {
                param["comp_reg_img"] = file
            }
            param["kind"] = ShareData.ins.kind.rawValue
            param["user_no"] = ShareData.ins.userNo
            
            ApiManager.ins.requestModifyStoreInfo(param) { res in
                if res["success"].boolValue {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }

        }
    }
    override func displayImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        let picker = CImagePickerController.init(sourceType) { (orig, crop) in
            guard let orig = orig, let crop = crop else {
                return
            }
            let fileName = Date().stringDateWithFormat("yyyyMMddHHmmss")
            let ext = "jpg"
            self.tfFile.text = fileName+"."+ext
            self.file = crop
            print("== orig: \(orig), crop:\(crop)")
        }
        self.present(picker, animated: true, completion: nil)
    }
}

extension ModifyStoreInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
