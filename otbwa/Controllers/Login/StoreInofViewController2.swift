//
//  StoreInofViewController2.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import UIKit
import SwiftyJSON

class StoreInofViewController2: BaseViewController {
    
    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!

    @IBOutlet weak var tfCompanyNum: CTextField!
    @IBOutlet weak var btnFile: CButton!
    @IBOutlet weak var tfFileName: CTextField!
    @IBOutlet weak var tfStoreName: CTextField!
    @IBOutlet weak var tfStoreNamePre: CTextField!
    @IBOutlet weak var btnCheckStoreName: CButton!
    
    @IBOutlet weak var tfPhone: CTextField!
    @IBOutlet weak var btnPostCode: CButton!
    @IBOutlet weak var tfPostCode: CTextField!
    @IBOutlet weak var tfAddr: CTextField!
    @IBOutlet weak var tfAddrDetail: CTextField!
    
    @IBOutlet weak var btnTermTotal: UIButton!
    @IBOutlet weak var btnTermUsing: UIButton!
    @IBOutlet weak var btnTermPrivacy: UIButton!
    @IBOutlet weak var btnTermSms: UIButton!
    @IBOutlet weak var tfStoreImageName: CTextField!
    @IBOutlet weak var btnStoreImageUpload: CButton!
    @IBOutlet weak var svStoreImage: UIStackView!
    @IBOutlet weak var svLink: UIStackView!
    @IBOutlet weak var tfLink: CTextField!
    
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var user: UserInfo!
    
    var checkStoreName: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "소매 회원가입", nil)
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        
        self.addTapGestureKeyBoardDown()
        tfCompanyNum.inputAccessoryView = toolBar
        tfStoreName.inputAccessoryView = toolBar
        tfStoreNamePre.inputAccessoryView = toolBar
        tfPhone.inputAccessoryView = toolBar
        tfAddrDetail.inputAccessoryView = toolBar
        tfPhone.inputAccessoryView = toolBar
        tfLink.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor:#selector(actionKeybardDown))
        safetyView.isHidden = !isEdgePhone
        
        btnNext.setBackgroundImage(UIImage.color(from: RGB(203, 203, 203)), for: .disabled)
        btnNext.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .normal)
        
        btnTermTotal.titleLabel?.numberOfLines = 0
        btnTermUsing.titleLabel?.numberOfLines = 0
        btnTermPrivacy.titleLabel?.numberOfLines = 0
        btnTermSms.titleLabel?.numberOfLines = 0
        
        svStoreImage.isHidden = true
        svLink.isHidden = true
        
        if user.onlineYN == "Y" {
            svLink.isHidden = false
        }
        else {
            svStoreImage.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnFile {
            btnFile.isSelected = true
            btnStoreImageUpload.isSelected = false
            let vc = ImageSelectOptionViewController.initWithCompletion { vcs, soureType in
                vcs?.dismiss(animated: true, completion: nil)
                self.showImagePicker(soureType)
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if sender == btnStoreImageUpload {
            btnFile.isSelected = false
            btnStoreImageUpload.isSelected = true
            let vc = ImageSelectOptionViewController.initWithCompletion { vcs, soureType in
                vcs?.dismiss(animated: true, completion: nil)
                self.showImagePicker(soureType)
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if sender == btnCheckStoreName {
            guard let text = tfStoreNamePre.text, text.isEmpty == false else {
                self.showToast("예비 상호명을 입력해주세요.")
                return
            }
            self.checkStoreName = false
            ApiManager.ins.requestCheckStoreName(text) { res in
                let success = res["success"].boolValue
                
                if success {
                    let dupYN = res["data"]["dupYN"]
                    if dupYN == "N" {
                        self.showToast("사용 가능한 예비 상호명입니다.")
                        self.checkStoreName = true
                    }
                    else {
                        self.showToast("중복된 예비 상호명입니다.")
                    }
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnPostCode {
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
                self.tfAddrDetail.text = ""
                self.tfAddrDetail.becomeFirstResponder()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnTermTotal {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnTermUsing.isSelected = true
                btnTermPrivacy.isSelected = true
                btnTermSms.isSelected = true
            }
            else {
                btnTermUsing.isSelected = false
                btnTermPrivacy.isSelected = false
                btnTermSms.isSelected = false
            }
        }
        else if sender == btnTermUsing {
            sender.isSelected = !sender.isSelected
            if sender.isSelected  && btnTermPrivacy.isSelected && btnTermSms.isSelected {
                btnTermTotal.isSelected = true
            }
            else {
                btnTermTotal.isSelected = false
            }
        }
        else if sender == btnTermPrivacy {
            sender.isSelected = !sender.isSelected
            if sender.isSelected  && btnTermUsing.isSelected && btnTermSms.isSelected {
                btnTermTotal.isSelected = true
            }
            else {
                btnTermTotal.isSelected = false
            }
        }
        else if sender == btnTermSms {
            sender.isSelected = !sender.isSelected
            if sender.isSelected  && btnTermUsing.isSelected && btnTermPrivacy.isSelected {
                btnTermTotal.isSelected = true
            }
            else {
                btnTermTotal.isSelected = false
            }
        }
        else if sender == btnNext {
            guard let lincense = tfCompanyNum.text, lincense.isEmpty == false else {
                self.showToast("사업자 번호를 입력해주세요.")
                return
            }
            guard lincense.contains("-") == true else {
                self.showToast("사업자번호에 '-'를 추가해주세요.")
                return
            }
            guard let _ = user.comp_reg_img  else {
                self.showToast("사업자 등록증 파일 등록해주세요.")
                return
            }
            guard let storeName = tfStoreName.text, storeName.isEmpty == false else {
                self.showToast("상호명을 입력해주세요.")
                return
            }
            if let storeNamePre = tfStoreNamePre.text, storeNamePre.isEmpty == false {
                if checkStoreName == false { //값이 있으면 중복 체크 요청
                    self.showToast("예비상호명 중복체크를 해주세요.")
                    return
                }
                else {
                    user.comp_nm_scd = storeNamePre
                }
            }
            
            guard let tel = tfPhone.text, tel.isEmpty == false else {
                self.showToast("전화번호를 입력해주세요.")
                return
            }
            
            guard let addr = tfAddr.text, addr.isEmpty == false else {
                self.showToast("주소를 입력해주세요.")
                return
            }
            var fullAddr = addr
            if let detailAddr = tfAddrDetail.text, detailAddr.isEmpty == false {
                fullAddr.append(" \(detailAddr)")
            }
            if user.onlineYN == "Y" {
                guard let link = tfLink.text, link.isEmpty == false else {
                    self.showToast("온라인 판매 링크를 입력해주세요.")
                    return
                }
                user.link = link
            }
            
            if btnTermUsing.isSelected == false {
                self.showToast("이용약관 동의해주세요.")
                return
            }
            if btnTermPrivacy.isSelected == false {
                self.showToast("개인정보수집 및 이용에 동의해주세요.")
                return
            }
            user.comp_nm = storeName
            user.comp_num = lincense
            user.tel = tel
            user.termUse = "Y"
            user.infoUse = "Y"
            user.smsUse = btnTermSms.isSelected ? "Y" : "N"
            user.comp_addr = fullAddr
            
            if let address = tfAddr.text, address.isEmpty == false {
                var addr = address;
                if let addrDetail = tfAddrDetail.text, addrDetail.isEmpty == false {
                    addr.append(" \(addrDetail)")
                }
                user.comp_addr = addr
            }
            
            guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
                self.showToast("uuid 오류")
                return
            }
            
            user.unique = KeychainItem.currentUserIdentifier
            user.uuid = uuid.lowercased()
            
            let param = user.map()
            ApiManager.ins.requestSignup(param) { res in
                let success = res["success"].boolValue
                if success {
                    
                    UserDefaults.standard.setValue(uuid, forKey: Dfskey.uniqueId)
                    UserDefaults.standard.setValue(self.user.id!, forKey: Dfskey.userId)
                    UserDefaults.standard.setValue(self.user.pw!, forKey: Dfskey.userPw)
                    UserDefaults.standard.synchronize()
                    
                    let vc = JoinCompletionViewController.instantiateFromStoryboard(.login)!
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
    }
    
    func showImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        let vc = CImagePickerController.initWithSouretType(sourceType, true, 1) { data in
            guard let data = data as? UIImage else {
                return
            }
            let fileName = Date().stringDateWithFormat("yyyyMMddHHmmss")
            let ext = "jpg"
            if self.btnFile.isSelected {
                self.tfFileName.text = fileName+"."+ext
                self.user.comp_reg_img = data
            }
            else {
                self.tfStoreImageName.text = fileName+"."+ext
                self.user.img = data
            }
            print("== orig: \(data)")
        }
        self.present(vc, animated: true, completion: nil)
    }
}

extension StoreInofViewController2: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfCompanyNum {
            tfStoreName.becomeFirstResponder()
        }
        else if textField == tfStoreName {
            tfStoreNamePre.becomeFirstResponder()
        }
        else if textField == tfStoreNamePre {
            tfPhone.becomeFirstResponder()
        }
        else if textField == tfPhone {
            tfAddrDetail.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text,
              let textRange = Range(range, in: text) else {
            return false
        }
        let _ = text.replacingCharacters(in: textRange, with: string)
        if textField == tfStoreNamePre {
            self.checkStoreName = false
        }
        return true
    }

}
