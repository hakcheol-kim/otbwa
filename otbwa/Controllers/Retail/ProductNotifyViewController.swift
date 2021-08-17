//
//  ProductNotifyViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON
class ProductNotifyCell: UITableViewCell {
    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var lbSubTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
class ProductNotifyViewController: BaseViewController {
    @IBOutlet var tblView: UITableView!

    var listData = [JSON]()
    var page:Int = 1
    var canRequest = true;
    var isPageEnd = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.tableFooterView = UIView()
    }
    
    func dataRest() {
        print("알림")
        self.page = 1
        self.canRequest = true
        self.isPageEnd = false
        self.requestNofifyList()
    }
    func addData() {
        self.requestNofifyList()
    }
    func requestNofifyList() {
        if isPageEnd == true {
            return
        }
        
        var param = [String:Any]()
        param["kind"] = ShareData.ins.kind.rawValue
        param["p_current"] = page
        param["user_no"] = ShareData.ins.userNo
        
        ApiManager.ins.requestNotificationInfo(param: param) { res in
            let success = res["success"].boolValue
            if success {
                let list = res["data"]["inform_list"].arrayValue
                if list.count == 0 {
                    self.isPageEnd = true
                }
                
                if self.page == 1 {
                    self.listData = list
                }
                else {
                    self.listData.append(contentsOf: list)
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
}

extension ProductNotifyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductNotifyCell") as? ProductNotifyCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.lbTitle.text = item["title"].stringValue
        cell.lbSubTitle.text = item["date"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProductNotifyViewController: UIScrollViewDelegate {
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
