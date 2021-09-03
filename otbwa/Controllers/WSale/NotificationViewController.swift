//
//  NotificationViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/31.
//

import UIKit
import SwiftyJSON
class NotificationViewController: BaseViewController {
    @IBOutlet weak var btnPush: UIButton!
    @IBOutlet weak var btnDisturb: UIButton!
    @IBOutlet weak var btnSetting: CButton!
    @IBOutlet weak var tfStart: CTextField!
    @IBOutlet weak var tfEnd: CTextField!
    
    var passData:JSON!
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "알림/방해금지모드 설정")
        
        tfStart.inputAccessoryView = toolBar
        tfEnd.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        self.addTapGestureKeyBoardDown()
        btnSetting.titleLabel?.numberOfLines = 0
        btnSetting.titleLabel?.textAlignment = .center
        btnSetting.setTitle("혹시 알림이 동작 안되시면\n여기를 클릭하여 시스템 알림설정을 확인해주세요.", for: .normal)
        
        self.decorationUi()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func decorationUi() {
        let notification_yn = passData["notification_yn"].stringValue
        if notification_yn == "Y" {
            btnPush.isSelected = true
        }
        else {
            btnPush.isSelected = false
        }
        
        let disturb_yn = passData["disturb_yn"].stringValue
        if disturb_yn == "Y" {
            btnDisturb.isSelected = true
        }
        else {
            btnDisturb.isSelected = false
        }
        
        let disturb_start = passData["disturb_start"].stringValue
        let disturb_end = passData["disturb_end"].stringValue
        tfStart.text = disturb_start
        tfEnd.text = disturb_end
    }
    @IBAction func textFieldEdtingChange(_ textField: UITextField) {
        guard let text = textField.text, let newTxt = text.getNumberString(), newTxt.isEmpty == false else {
            textField.text = ""
            return
        }
        
        var timStr = newTxt
        if newTxt.length > 4 {
            timStr = String(newTxt.suffix(4))
        }
        
        if timStr.length == 4 {
            let time = String(timStr.prefix(2))
            let min = String(timStr.suffix(2))
            textField.text = "\(time):\(min)"
        }
        else if timStr.length == 3 {
            let time = String(timStr.prefix(2))
            let min = String(timStr.suffix(1))
            textField.text = "\(time):\(min)"
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPush {
            sender.isSelected = !sender.isSelected
            self.requestNotificationStting()
        }
        else if sender == btnDisturb {
            if sender.isSelected == false && checkAvailableTime() == true {
                sender.isSelected = true
                self.requestNotificationStting()
            }
            else if sender.isSelected == true {
                sender.isSelected = false
                self.requestNotificationStting()
            }
        }
        else if sender == btnSetting {
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }
    }
    
    func checkAvailableTime() ->Bool {
        guard let st = tfStart.text, st.isEmpty == false else {
            self.showToast("시작 시간을 입력해주세요.")
            return false
        }
        guard let ed = tfEnd.text, ed.isEmpty == false else {
            self.showToast("종료 시간을 입력해주세요.")
            return false
        }
        
        let comp1 = st.components(separatedBy: ":")
        let comp2 = ed.components(separatedBy: ":")
        
        guard let time1 = Int(comp1.first!), time1 <= 24,
           let time2 = Int(comp2.first!), time2 <= 24 else {
            self.showToast("시간은 24시간 보다 작아야 합니다.")
            return false
        }
        guard let min1 = Int(comp1.last!), min1 <= 60,
              let min2 = Int(comp2.last!), min2 <= 60 else {
            self.showToast("분은 60분 보다 작아야 합니다.")
            return false
        }
        return true
    }
    
    func requestNotificationStting() {
        var param = [String:Any]()
        param["user_no"] = ShareData.ins.userNo
        param["notification_yn"] = (btnPush.isSelected ? "Y":"N")
        param["disturb_yn"] = "N"
        if btnDisturb.isSelected {
            param["disturb_st"] = tfStart.text!
            param["disturb_end"] = tfEnd.text!
            param["disturb_yn"] = "Y"
        }
        
        ApiManager.ins.requestNotificationStting(param) { res in
            if res["success"].boolValue {
                self.showToast("알람설정이 변경되었습니다.")
                UserDefaults.standard.setValue(param["notification_yn"], forKey: Dfskey.notification_yn)
                UserDefaults.standard.setValue(param["disturb_yn"], forKey: Dfskey.disturb_yn)
                UserDefaults.standard.setValue(param["disturb_st"], forKey: Dfskey.disturb_st)
                UserDefaults.standard.setValue(param["disturb_end"], forKey: Dfskey.disturb_end)
                UserDefaults.standard.synchronize()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
}
extension NotificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

