//
//  ProductRecentViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class ProductRecentViewController: BaseViewController {
    
    @IBOutlet var tblView: UITableView!
    @IBOutlet var btnTotalDel: CButton!
    @IBOutlet var btnDel: CButton!
    @IBOutlet var bottomBar: ShadowView!
    @IBOutlet var safetyView: UIView!
    
    var listData = [JSON]()
    var selectedItems = [JSON]()
    var type: TableViewType = .normal {
        didSet {
            selectedItems.removeAll()
            btnDel.setTitle("선택삭제", for: .normal)
            bottomBar.isHidden = (type == .normal)
            tblView.reloadData()
        }
    }
    var completion:((_ action:Int) ->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.tableFooterView = UIView()
        safetyView.isHidden = !isEdgePhone
    }
    
    func dataRest() {
        print("최근 본 상품")
        self.type = .normal
        self.requstRecentProductList()
    }
    func requstRecentProductList() {
        ApiManager.ins.requestRecentProducts(param: ["user_no" : ShareData.ins.userNo]) { res in
            let success = res["success"].boolValue
            if success {
                self.listData = res["data"]["list"].arrayValue
                self.tblView.reloadData()
            }
            else {
                self.listData.removeAll()
                self.tblView.reloadData()
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnDel {
            if self.selectedItems.count == 0 {
                self.showToast("선택해주세요.")
                return
            }
            self.requestDeleteProductRecent()
        }
        else if sender == btnTotalDel {
            self.selectedItems = listData
            self.requestDeleteProductRecent()
        }
    }
    
    func requestDeleteProductRecent() {
        guard selectedItems.isEmpty == false else {
            return
        }
        var param = [String:Any]()
        var list = [Any]()
        for item in self.selectedItems {
            list.append(item["product_no"].intValue)
        }
        param["list"] = list
        param["user_no"] = ShareData.ins.userNo
        ApiManager.ins.requestDeleteRecentProducts(param: param) { res in
            let success = res["success"].boolValue
            if  success {
                self.dataRest()
                self.completion?(100)
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
}
extension ProductRecentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ProdcutCell") as? ProdcutCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("ProdcutCell", owner: nil, options: nil)?.first as? ProdcutCell
        }
        
        let item = listData[indexPath.row]
        if let _ = self.selectedItems.firstIndex(of: item) {
            cell?.configuratonData(item, type, true)
        }
        else {
            cell?.configuratonData(item, type, false)
        }
        
        cell?.completion = {(_ item:JSON, _ isSelected:Bool)-> Void in
            if let index = self.selectedItems.firstIndex(of: item) {
                if isSelected == false {
                    self.selectedItems.remove(at: index)
                }
            }
            else if isSelected {
                self.selectedItems.append(item)
            }
            if self.selectedItems.count == 0 {
                self.btnDel.setTitle("선택삭제", for: .normal)
            }
            else {
                self.btnDel.setTitle("선택삭제(\(self.selectedItems.count))", for: .normal)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        appDelegate.mainNaviCtrl.pushViewController(vc, animated: true)
    }
}
