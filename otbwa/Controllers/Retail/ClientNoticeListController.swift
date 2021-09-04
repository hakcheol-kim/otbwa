//
//  ClientNoticeListController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/19.
//

import UIKit
import SwiftyJSON

enum NoticeViewType {
    case normal, edting
}
class ClientNoticeCell: UITableViewCell {
    @IBOutlet weak var svContainer: UIStackView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnModify: CButton!
    @IBOutlet weak var btnDel: CButton!
    
    var data: JSON!
    
    var completion:((_ data: Any?, _ action: Int) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data:JSON, _ type: NoticeViewType = .normal) {
        self.data = data
        if type == .edting {
            btnModify.isHidden = false
            btnDel.isHidden = false
            svContainer.spacing = 0
            btnDel.setNeedsDisplay()
            btnModify.setNeedsDisplay()
        }
        else {
            btnModify.isHidden = true
            btnDel.isHidden = true
            svContainer.spacing = 4
        }
        let date = data["date"].stringValue
        let title = data["title"].stringValue
        
        lbTitle.text = title
        lbDate.text = date
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnModify {
            self.completion?(data, 1)
        }
        else if sender == btnDel {
            self.completion?(data, 2)
        }
    }
}

class ClientNoticeListController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnWrite: CButton!
    
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
        
        self.tblView.tableFooterView = UIView()
        tblView.estimatedRowHeight = 60
        tblView.rowHeight = UITableView.automaticDimension
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        else if sender ==  btnWrite {
            let vc = ClientNoticeEdtingViewController.initWithType(.regist)
            self.navigationController?.pushViewController(vc, animated: true)
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
                }
                self.tblView.reloadData()
                self.page += 1
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func gotoModifyVc(_ item:JSON) {
        let vc = ClientNoticeEdtingViewController.initWithType(.modify, item)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func deleteNotice(_ item:JSON) {
        
    }
}

extension ClientNoticeListController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientNoticeCell") as? ClientNoticeCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configurationData(item, type)
        cell.completion = {(data, action) ->Void in
            guard let data = data as? JSON else {
                return
            }
            if action == 1 { //수정
                self.gotoModifyVc(data)
            }
            else if action == 2 { //삭제
                self.deleteNotice(data)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = ClientNoticeDetailViewController.instantiateFromStoryboard(.main)!
        vc.data = item
        self.navigationController?.pushViewController(vc, animated: true)
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
