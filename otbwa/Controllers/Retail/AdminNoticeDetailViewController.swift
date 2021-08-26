//
//  AdminNoticeDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON
class AdminNoticeDetailViewController: BaseViewController {
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var textView: CTextView!
    
    var passData: JSON!
    var data: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "관리자 공지사항", nil)

        requestAdminNoticeDetail()
    }
    func requestAdminNoticeDetail() {
        let notice_no = passData["notice_no"].intValue
        ApiManager.ins.requestAdminNoticeDetail(noticeNo: notice_no) { res in
            if res["success"].boolValue {
                self.data = res["data"]
                self.decorationUI()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
    func decorationUI() {
        let content = data["content"].stringValue
        let date = data["date"].stringValue
        let title = data["title"].stringValue
        
        lbDate.text = date
        lbTitle.text = title
        textView.text = content
    }
}
