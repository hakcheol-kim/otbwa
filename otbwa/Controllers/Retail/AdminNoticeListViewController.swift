//
//  AdminNoticeListViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON
class AdminNoticeCell: UITableViewCell {
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data: JSON) {
        let title = data["title"].stringValue
        let date = data["date"].stringValue
        lbTitle.text = title
        lbDate.text = date
    }
}

class AdminNoticeListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    var listData = [JSON]()
    var page = 1
    var canRequest = true
    var isPageEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "관리자 공지사항")
        self.tblView.tableFooterView = UIView()
        self.dataReset()
    }
 
    func dataReset() {
        page = 1
        canRequest = true
        isPageEnd = false
        self.requestAdminNoticeList()
    }
    func addData() {
        self.requestAdminNoticeList()
    }
    func requestAdminNoticeList() {
        if isPageEnd == true || canRequest == false {
            return
        }
        canRequest = false
        
        let param = ["kind": ShareData.ins.kind.rawValue, "p_current": page] as [String:Any]
        ApiManager.ins.requestAdminNoticeList(param) { res in
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
                
                if (self.listData.isEmpty == true) {
                    self.tblView.isHidden = true
                }
                else {
                    self.tblView.isHidden = false
                    self.tblView.reloadData()
                }
            }
            else {
                self.isPageEnd = true
            }
        } fail: { error in
            self.showErrorToast(error)
        }

        
    }
    
}
extension AdminNoticeListViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdminNoticeCell") as? AdminNoticeCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configurationData(item)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = AdminNoticeDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            self.addData()
        }
    }
}
