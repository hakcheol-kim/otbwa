//
//  RoomSelectedViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit
import SwiftyJSON
class RoomSelectedViewController: BaseViewController {
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var tblView: UITableView!
    
    var completion:((_ item: Any?) ->Void)?
    var selFloor: JSON!
    var page: Int = 1
    var listData = [JSON]()
    var isPageEnd: Bool = false
    var canRequest: Bool = true
    
    static func initWithCompletion(_ floor:JSON, completion:((_ item:Any?) ->Void)?) ->RoomSelectedViewController {
        let vc = RoomSelectedViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        vc.selFloor = floor
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestBuildingUnit()
    }
    
    func dataReset() {
        page = 1
        isPageEnd = false
        canRequest = true
        self.requestBuildingUnit()
    }
    func addData() {
        self.requestBuildingUnit()
    }
    func requestBuildingUnit() {
        if isPageEnd == true || canRequest == false {
            return
        }
        canRequest = false
        let category_no = selFloor["ctgr_no"].intValue
        let param:[String:Any] = ["category_no" : category_no, "p_current": page]
        ApiManager.ins.requestBuildingUnit(param) { res in
            self.canRequest = true
            let success = res["success"].boolValue
            if success {
                let list = res["data"]["list"].arrayValue
                
                if list.count == 0 {
                    self.isPageEnd = true
                }
                
                if self.page == 1 {
                    self.listData = list
                }
                else {
                    self.listData.append(contentsOf: list)
                }
                
                if self.listData.isEmpty == true {
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
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnClose {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension RoomSelectedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PopupCell") as? PopupCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("PopupCell", owner: nil, options: nil)?.first as? PopupCell
        }
        
        let item = listData[indexPath.row]
        cell?.lbTitle.text = item["name"].stringValue
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        let item = listData[indexPath.row]
        completion?(item)
    }
}

extension RoomSelectedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            self.addData()
        }
    }
}
