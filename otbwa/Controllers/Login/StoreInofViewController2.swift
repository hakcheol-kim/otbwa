//
//  StoreInofViewController2.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import UIKit

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
    
    @IBOutlet weak var btnPhonePrifix: CButton!
    @IBOutlet weak var tfPhonePrifix: UITextField!
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
    var user: UserInfo = UserInfo()
    
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
        
        user.onlineYN = "Y"
        svStoreImage.isHidden = true
        svLink.isHidden = true
        
        if user.onlineYN == "Y" {
            svLink.isHidden = false
            svStoreImage.isHidden = true
        }
        else {
            svLink.isHidden = true
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
            sender.isSelected = true
            btnStoreImageUpload.isSelected = false
            self.uploadFile()
        }
        else if sender == btnStoreImageUpload {
            sender.isSelected = false
            btnStoreImageUpload.isSelected = true
            self.uploadFile()
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
            
        }
        else if sender == btnPhonePrifix {
            let phonePrifix = ["02","031","032","033","041","042","043","044","051","052","053","054","055","061","062","063","064"]
            
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
            
            guard let telPre = tfPhonePrifix.text, telPre.isEmpty == false else {
                self.showToast("지역 전화번호 앞자리를 선택해주세요.")
                return
            }
            guard let tel = tfPhone.text, tel.isEmpty == false else {
                self.showToast("전화번호를 입력해주세요.")
                return
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
            
            user.comp_num = lincense
            user.tel = tel
            user.termUse = "Y"
            user.infoUse = "Y"
            user.smsUse = btnTermSms.isSelected ? "Y" : "N"
            
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
            user.uuid = uuid
            
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
    func uploadFile() {
//        var alertStyle = UIAlertController.Style.actionSheet
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            alertStyle = .alert
//        }
//        let alert = UIAlertController(title:nil, message: nil, preferredStyle: alertStyle)
//        alert.addAction(UIAlertAction(title: "카메라로 사진 촬영하기", style: .default, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//            self.showCameraPicker(.camera)
//        }))
//        alert.addAction(UIAlertAction(title: "갤러리에서 사진 가져오기", style: .default, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//            self.showCameraPicker(.photoLibrary)
//        }))
//        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }))
//        
//        present(alert, animated: true, completion: nil)
    }
//    func showCameraPicker(_ sourceType: UIImagePickerController.SourceType) {
//        let picker = CImagePickerController.init(sourceType) { (orig, crop) in
//            guard let orig = orig, let crop = crop else {
//                return
//            }
//
//            let fileName = Date().stringDateWithFormat("yyyyMMddHHmmss")
//            let ext = "jpg"
//            if self.btnFile.isSelected {
//                self.tfFileName.text = fileName+"."+ext
//                self.user.comp_reg_img = crop
//            }
//            else {
//                self.tfStoreImageName.text = fileName+"."+ext
//                self.user.img = crop
//            }
//            print("== orig: \(orig), crop:\(crop)")
//        }
//        self.present(picker, animated: true, completion: nil)
//    }
}

extension StoreInofViewController2: UITextFieldDelegate {
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
