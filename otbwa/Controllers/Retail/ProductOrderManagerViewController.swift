//
//  ProductOrderManagerViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit
import SwiftyJSON
class ProductOrderManagerViewController: BaseViewController {
    @IBOutlet weak var btnBuilding: CButton!
    @IBOutlet weak var tfBuilding: UITextField!
    @IBOutlet weak var btnMonth: CButton!
    @IBOutlet weak var tfMonth: UITextField!
    @IBOutlet weak var tfStoreSearch: UITextField!
    @IBOutlet weak var btnStoreSearch: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var toolBar = CToolbar(barItems: [.keyboardDown])
    var listData = [JSON]()
    
    var page: Int = 1
    var canRequest = true
    var isPageEnd = false
    var selMonth:[String:Any]? {
        didSet {
            guard let selMonth = selMonth else {
                return
            }
            self.tfMonth.text = selMonth["title"] as? String
            dataReset()
        }
    }
    var selBuilding:JSON? {
        didSet {
            guard let selBuilding = selBuilding else {
                return
            }
            self.tfBuilding.text = selBuilding["name"].stringValue
            dataReset()
        }
    }
    var builings = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "주문관리", nil)
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tfStoreSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        
        self.requestFilter()
        self.dataReset()
    }
    
    func requestFilter() {
        ApiManager.ins.requestFilterList { res in
            if res["success"].boolValue {
                let bAddr = res["data"]["building"].arrayValue
                self.builings = bAddr.filter({ item ->Bool in
                    return item["level"].intValue == 2
                })
                
                let tmp = JSON(["name":"건물 선택", "ctgr_no": "-1"])
                self.builings.insert(tmp, at: 0)
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
    func dataReset() {
        canRequest = true
        isPageEnd = false
        page = 1
        requestOrderProductList()
    }
    func addData() {
        requestOrderProductList()
    }
    func requestOrderProductList() {
        if isPageEnd == true {
            return
        }
        
        var param = [String:Any]()
        param["user_no"] = ShareData.ins.userNo
        param["p_current"] = page
        if let selMonth = selMonth {
            let code = selMonth["code"] as? String
            if code != "-1" {
                param["month"] = code
            }
        }
        if let selBuilding = selBuilding {
            let ctgr_no = selBuilding["ctgr_no"].stringValue
            if ctgr_no != "-1" {
                param["building"] = ctgr_no
            }
        }
        if let text = tfStoreSearch.text, text.isEmpty == false {
            param["name"] = text
        }
        
        ApiManager.ins.requestOrderProductList(param) { res in
            self.canRequest = true
            if res["success"].boolValue {
                let list = res["data"].arrayValue
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
                self.tableView.reloadData()
            }
            else {
                self.showErrorToast(res)
                self.listData.removeAll()
                self.tableView.reloadData()
            }
        } fail: { error in
            self.showErrorToast(error)
            self.listData.removeAll()
            self.tableView.reloadData()
            self.isPageEnd = true
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMonth {
            let list = [["code": "-1", "title": "월 단위로 보기"],
                        ["code": "3d", "title": "3일"],
                        ["code": "1w", "title": "1주일"],
                        ["code": "1m", "title": "1개월"],
                        ["code": "3m", "title": "3개월"],
                        ["code": "6m", "title": "6개월"]]
            let vc = PopupListViewController.initWithType(.normal, nil, list, ["title"]) { vcs, item, index in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? [String: Any] else {
                    return
                }
                self.selMonth = item
            }
            self.presentPanModal(vc)
        }
        else if sender == btnBuilding {
            
            let vc = PopupListViewController.initWithType(.normal, nil, self.builings, ["name"]) { vcs, item, index in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? JSON else {
                    return
                }
                self.selBuilding = item
            }
            self.presentPanModal(vc)
        }
        else if sender == btnStoreSearch {
            tfStoreSearch.becomeFirstResponder()
        }
    }
}

extension ProductOrderManagerViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductOrderManagerCell") as? ProductOrderManagerCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configurationData(item)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
     
        let vc = ProductOrderDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
//            canRequest = false
//            self.addData()
        }
    }
}

extension ProductOrderManagerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.dataReset()
        return true
    }
}
