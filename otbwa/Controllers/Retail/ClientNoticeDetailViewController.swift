//
//  ClientNoticeDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/19.
//

import UIKit
import SwiftyJSON

class ClientNoticeDetailViewController: BaseViewController {
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var textView: CTextView!
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var btnCancel: CButton!
    
    var data:JSON!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "공지사항", nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestNotitceDetail()
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
        let date = data["date"].stringValue
        let title = data["title"].stringValue
        let content = data["content"].stringValue
        
        lbTitle.text = title
        lbDate.text = date
        textView.text = content
        textView.placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnOk {
            let vc = ClientNoticeEdtingViewController.initWithType(.modify, data)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnCancel {
            guard let data = data, data.isEmpty == false else {
                return
            }
            
            let vc = CAlertViewController.init(type: .alert, message: "공지사항을 삭제하시겠습니까?") { vcs, action in
                vcs.dismiss(animated: true, completion: nil)
                
                let notice_no = data["notice_no"].intValue
                var param = [String:Any]()
                param["notice_no"] = notice_no
                param["comp_no"] = ShareData.ins.compNo
                
                ApiManager.ins.requestDeleteCompNotice(param) { res in
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
            vc.addAction(.ok, "삭제")
            self.present(vc, animated: true, completion: nil)
        }
    }
}
extension ClientNoticeDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
}
