//
//  ClientNoticeEdtingViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/19.
//

import UIKit
import SwiftyJSON
enum ClientNoticeType {
    case regist, modify
}

class ClientNoticeEdtingViewController: BaseViewController {
    
    class func initWithType(_ type: ClientNoticeType, _ data:JSON? = nil) -> ClientNoticeEdtingViewController {
        let vc = ClientNoticeEdtingViewController.instantiateFromStoryboard(.main)!
        vc.type = type
        vc.data = data
        return vc
    }
    
    @IBOutlet weak var tfTitle: CTextField!
    @IBOutlet weak var tvContent: CTextView!
    
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var btnCancel: CButton!
    @IBOutlet weak var safetyView: UIView!
    var type:ClientNoticeType = .regist
    
    var data: JSON?
    let toolbar = CToolbar.init(barItems: [.keyboardDown])
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "거래처 공지")
        
        tfTitle.inputAccessoryView = toolbar
        tvContent.inputAccessoryView = toolbar
        toolbar.addTarget(self, selctor: #selector(actionKeybardDown))
       
        if type == .modify {
            self.requestNotitceDetail()
            btnOk.setTitle("수정하기", for: .normal)
        }
        else {
            btnOk.setTitle("공지사항 등록", for: .normal)
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
    
    func requestNotitceDetail() {
        guard let data = data, data.isEmpty == false else {
            return
        }
        
        let notice_no = data["notice_no"].intValue
        ApiManager.ins.requestCompNoticeDetail(notice_no) { res in
            if res["success"].boolValue {
                self.data = res["data"];
                self.configurationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
    
    func configurationUi() {
        guard let data = data, data.isEmpty == false else {
            return
        }
        let notice_no = data["notice_no"].intValue
        let title = data["title"].stringValue
        let content = data["content"].stringValue
        let date = data["date"].stringValue
        
        tfTitle.text = title
        tvContent.text = content
        tvContent.placeholderLabel?.isHidden = !tvContent.text.isEmpty
    }
    
    @IBAction func onClickBtnActions(_ sender: UIButton) {
        if sender == btnOk {
            guard let title = tfTitle.text, title.isEmpty == false else {
                self.showToast("제목을 입력해주세요.")
                return
            }
            guard let content = tvContent.text, title.isEmpty == false else {
                self.showToast("내용을 입력해주세요.")
                return
            }
            var param = [String:Any]()
            param["cntnt"] = content
            param["title"] = title
            param["user_no"] = ShareData.ins.userNo
            param["comp_no"] = ShareData.ins.compNo
            
            if type == .regist {
                ApiManager.ins.requestRegiestCompNotice(param) { res in
                    if res["success"].boolValue {
                        appDelegate.window?.makeToast("공지사항이 등록되었습니다.")
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { error in
                    self.showErrorToast(error)
                }

            }
            else {
                param["notice_no"] = self.data!["notice_no"].intValue
                ApiManager.ins.requestModifyCompNotice(param) { res in
                    if res["success"].boolValue {
                        appDelegate.window?.makeToast("공지사항이 수정되었습니다.")
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
        else if sender == btnCancel {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension ClientNoticeEdtingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
}
