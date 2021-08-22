//
//  PartnerNoticeController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/19.
//

import UIKit
import SwiftyJSON

enum NoticeViewType {
    case normal, edting
}
class NoticeCell: UITableViewCell {
    @IBOutlet weak var svContainer: UIStackView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnModify: CButton!
    @IBOutlet weak var btnDel: CButton!
    
    var completion:((_ action: Int) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data:JSON, _ type: NoticeViewType = .normal) {
        if type == .edting {
            btnModify.isHidden = false
            btnDel.isHidden = false
            svContainer.spacing = 0
        }
        else {
            btnModify.isHidden = true
            btnDel.isHidden = true
            svContainer.spacing = 4
        }
        
        
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnModify {
            self.completion?(1)
        }
        else if sender == btnDel {
            self.completion?(2)
        }
    }
}

class NoticeListController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!

    var comp_no: Int = 0
    
    var page:Int = 1
    var canRequest = true;
    var isPageEnd = false
    
    var listData = [JSON]()
    var type: NoticeViewType  = .normal {
        didSet {
            self.tblView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "거래처 공지", nil)
        CNavigationBar.drawRight(self, nil, "수정", 1001, #selector(onClickedBtnActions(_ :)))
        self.tblView.layer.cornerRadius = 6
        tblView.clipsToBounds = true
        
        self.dataReset()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == 1001 {
            if type == .normal {
                CNavigationBar.drawRight(self, nil, "완료", 1001, #selector(onClickedBtnActions(_ :)))
                type = .edting
            }
            else {
                CNavigationBar.drawRight(self, nil, "수정", 1001, #selector(onClickedBtnActions(_ :)))
                type = .normal
            }
        }
        else {
            
        }
    }
    func dataReset() {
        self.page = 1
        self.canRequest = true
        self.isPageEnd = false
        self.requestNoticeList()
    }
    func addData() {
        self.requestNoticeList()
    }
    
    func requestNoticeList() {
        if isPageEnd == true { return }
        let param = ["comp_no": comp_no, "p_current": page]
        ApiManager.ins.requestNoticeList(param) { res in
            self.canRequest = true
            if res["success"].boolValue {
                let list = res["data"]["list"].arrayValue
                if list.isEmpty == true {
                    self.isPageEnd = true
                }
                
                if self.page == 1 {
                    self.listData = list
                }
                else {
                    self.listData.append(contentsOf: list)
                }
                
                if self.listData.count == 0 {
                    self.tblView.isHidden = true
                }
                else {
                    self.tblView.isHidden = false
                    self.tblView.reloadData()
                }
                self.page += 1
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
}

extension NoticeListController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell") as? NoticeCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configurationData(item, type)
        cell.completion = {(action) ->Void in
            if action == 1 { //수정
                
            }
            else if action == 2 { //삭제
                
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            canRequest = false
            self.addData()
        }
    }
}
