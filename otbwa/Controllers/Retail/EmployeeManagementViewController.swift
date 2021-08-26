//
//  EmployeeManagementViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit
import SwiftyJSON
class EmployeeManagementCell: UITableViewCell {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var btnCancel: CButton!
    
    var completion: ((_ item:Any?, _ action:Int) ->Void)?
    var data:JSON!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data: JSON) {
        self.data = data
        let user_no = data["user_no"].stringValue
        let name = data["name"].stringValue
        let phone = data["phone"].stringValue
        let status = data["status"].stringValue
        
        lbTitle.text = name
        lbSubTitle.text = phone
        
        if status == "승인완료" {
            btnOk.isHidden = true
        }
        else {
            btnOk.isHidden = false
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnOk {
            self.completion?(self.data, 100)
        }
        else if sender == btnCancel {
            self.completion?(self.data, 200)
        }
    }
}



class EmployeeManagementViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    var listData = [JSON]()
    var page = 1
    var canRequest = true
    var isPageEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "직원 관리", nil)
        tblView.tableFooterView = UIView()
        self.requestEmployeeList()
    }
    func dataRest() {
        page = 1
        canRequest = true
        isPageEnd = false
        self.requestEmployeeList()
    }
    func addData() {
        self.requestEmployeeList()
    }
    func requestEmployeeList() {
        if isPageEnd == true {
            return
        }
        
        let param:[String:Any] = ["comp_no": ShareData.ins.compNo, "p_current": page]
        ApiManager.ins.requestEmployeeList(param) { res in
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
                self.page += 1
                self.tblView.reloadData()
            }
            else {
                self.isPageEnd = true
                if self.page == 1 {
                    self.listData.removeAll()
                }
                self.tblView.reloadData()
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func requestEmployeeManagement(_ param:[String:Any]) {
        ApiManager.ins.requestEmployeeManagement(param) { res in
            if res["success"].boolValue {
                self.dataRest()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
}

extension EmployeeManagementViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeManagementCell") as? EmployeeManagementCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configurationData(item)
        cell.completion = {(item, action) -> Void in
            guard let item = item as? JSON else {
                return
            }
            if action == 100 { //승인 완료
                let param = ["comp_no": ShareData.ins.compNo, "fn_value": "approved", "user_no": ShareData.ins.userNo] as [String : Any]
                self.requestEmployeeManagement(param)
            }
            else if action == 200 { //취소
                let param = ["comp_no": ShareData.ins.compNo, "fn_value": "reject", "user_no": ShareData.ins.userNo] as [String : Any]
                self.requestEmployeeManagement(param)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = listData[indexPath.row]
        
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
