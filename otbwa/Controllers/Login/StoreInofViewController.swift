//
//  StoreInofViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/31.
//

import UIKit
import SwiftyJSON

class StoreInofViewController: BaseViewController {

    @IBOutlet weak var topStepView: UIView!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var btnFile: CButton!
    @IBOutlet weak var tfFileName: CTextField!
    @IBOutlet weak var tfCompanyNum: CTextField!
    @IBOutlet weak var tfCompanyPhone: CTextField!
    @IBOutlet weak var tfHashTags: CTextField!
    @IBOutlet weak var btnHashTag: CButton!
    
    @IBOutlet weak var btnTermTotal: UIButton!
    @IBOutlet weak var btnTermUsing: UIButton!
    @IBOutlet weak var btnTermPrivacy: UIButton!
    @IBOutlet weak var btnTermSms: UIButton!
    
    var user: UserInfo!
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "도매 회원가입", nil)
        topStepView.layer.cornerRadius = 20
        topStepView.layer.maskedCorners = CACornerMask(TL: false, TR: false, BL: true, BR: true)
        
        self.addTapGestureKeyBoardDown()
        tfFileName.inputAccessoryView = toolBar
        tfCompanyNum.inputAccessoryView = toolBar
        tfCompanyPhone.inputAccessoryView = toolBar
        tfHashTags.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor:#selector(actionKeybardDown))
        safetyView.isHidden = !isEdgePhone
        
        btnTermTotal.titleLabel?.numberOfLines = 0
        btnTermUsing.titleLabel?.numberOfLines = 0
        btnTermPrivacy.titleLabel?.numberOfLines = 0
        btnTermSms.titleLabel?.numberOfLines = 0
        
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
        if sender == btnHashTag {
            let vc = HashTagViewController.initWithType(.hastagThree) { items in
                guard let tags = items as? [JSON] else {
                    return
                }
                
                var text = ""
                var ctgrs = "["
                
                for i in 0..<tags.count {
                    let item = tags[i]
                    let name = item["name"].stringValue
                    let ctgr_id = item["ctgr_no"].stringValue
                    
                    if i < (tags.count-1) {
                        text.append("\(name),")
                        ctgrs.append("\(ctgr_id),")
                    }
                    else {
                        text.append("\(name)")
                        ctgrs.append("\(ctgr_id)")
                    }
                }
                ctgrs.append("]")
                print(tags)
                print(ctgrs)
                self.user.hashtag = ctgrs
                self.tfHashTags.text = text
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if sender == btnFile {
            let vc = ImageSelectOptionViewController.initWithCompletion { vcs, soureType in
                vcs?.dismiss(animated: true, completion: nil)
                self.showImagePicker(soureType)
            }
            self.present(vc, animated: true, completion: nil)
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
            guard let _ = user.img  else {
                self.showToast("사업자 등록증 파일 등록해주세요.")
                return
            }
            guard let lincense = tfCompanyNum.text, lincense.isEmpty == false else {
                self.showToast("사업자 번호를 입력해주세요.")
                return
            }
            guard lincense.contains("-") == true else {
                self.showToast("사업자번호에 '-'를 추가해주세요.")
                return
            }
            guard let tel = tfCompanyPhone.text, tel.isEmpty == false else {
                self.showToast("전화번호를 입력해주세요.")
                return
            }
            guard let _ = self.user.hashtag else {
                self.showToast("해시태그를 선택해주세요.")
                return
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
            self.tfFileName.text = fileName+"."+ext
            self.user.img = data
            
            print("== orig: \(data)")
        }
        self.present(vc, animated: true, completion: nil)
    }
}
