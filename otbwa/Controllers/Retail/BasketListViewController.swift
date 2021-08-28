//
//  BasketListViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class BasketListCell: UITableViewCell {
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var ivthumb: UIImageView!
    @IBOutlet weak var btnModify: CButton!
    @IBOutlet weak var svOption: UIStackView!
    @IBOutlet weak var lbTotal: UILabel!
    
    var data:JSON!
    var index:Int = -1
    var completion: ((_ index:Int, _ action:Int) ->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selView = UIView()
        selView.backgroundColor = RGBA(255, 111, 72, 0.2)
        self.selectedBackgroundView = selView
    }
    
    func configuarationData(_ data: JSON, _ isSelected:Bool, _ index:Int) {
        self.data = data
        self.index = index
        
        let img = data["img"].stringValue
        let name = data["name"].stringValue
        let option = data["option"].arrayValue
        let pr_color = data["pr_color"].arrayValue
        let pr_size = data["pr_size"].stringValue
        let price = data["price"].numberValue
        let total_price = data["total_price"].numberValue
        
        btnCheck.isSelected = isSelected
        lbName.text = name
        lbPrice.text = price.toString()
        if img.isEmpty == false {
            ivthumb.setImageCache(img)
        }
        
        for subView in svOption.subviews {
            subView.removeFromSuperview()
        }
        for item in option {
            let sv = self.getOptionView(item)
            svOption.addArrangedSubview(sv)
        }
        
        lbTotal.text = total_price.toString()
        
    }
    
    func getOptionView(_ option:JSON) -> UIStackView {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 16)
        
        let lbTitle = UILabel.init()
        sv.addArrangedSubview(lbTitle)
        lbTitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbTitle.textColor = UIColor.label
        let color = option["color"].stringValue
        let size = option["size"].stringValue
        let cnt = option["cnt"].numberValue
        lbTitle.text = color + " / " + size
        lbTitle.setContentHuggingPriority(UILayoutPriority(rawValue: 255), for: .horizontal)
        
        let lbCount = UILabel.init()
        sv.addArrangedSubview(lbCount)
        lbCount.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbCount.textColor = UIColor.label
        lbCount.textAlignment = .right
        lbCount.text = cnt.toString()
        
        return sv
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCheck {
            sender.isSelected = !sender.isSelected
            self.completion?(self.index, 100)
        }
        else if sender == btnModify {
            self.completion?(self.index, 200)
        }
        
    }
}


class BasketListViewController: BaseViewController {
    @IBOutlet var tblView: UITableView!
    @IBOutlet weak var btnCheckAll: UIButton!
    @IBOutlet weak var btnCheckDel: UIButton!
    @IBOutlet weak var lbTotalPrice: UILabel!
    @IBOutlet weak var btnOrder: UIButton!
    
    var listData = [JSON]()
    var selIndex:Set<Int> = []
    
    var page: Int = 1
    var canRequest = true
    var isPageEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "장바구니")
        
        tblView.estimatedRowHeight = 100
        tblView.rowHeight = UITableView.automaticDimension
        
        lbTotalPrice.text = "0"
        btnCheckAll.isSelected = true
        self.dataReset()
    }
    func dataReset() {
        page = 1
        canRequest = true
        isPageEnd = false
        self.selIndex.removeAll()
        self.requestBasketList()
    }
    func addData() {
        self.requestBasketList()
    }
    
    func updateUi() {
        var sum: Int = 0
        for i in 0..<listData.count {
            if self.selIndex.contains(i) == true {
                let item = listData[i]
                sum += item["total_price"].intValue
            }
        }
        self.lbTotalPrice.text = "\(sum)"
    }
    
    func requestBasketList() {
        if isPageEnd == true {
            return
        }
        let param = ["p_current": page, "user_no":ShareData.ins.userNo]
        ApiManager.ins.requestBasketList(param: param) { res in
            self.canRequest = true
            if res["success"].boolValue == true {
                let data = res["data"].arrayValue
                if data.isEmpty == true {
                    self.isPageEnd = true
                }
                if self.page == 1 {
                    self.listData = data
                }
                else {
                    self.listData.append(contentsOf: data)
                }
                
                if self.btnCheckAll.isSelected == true {
                    for i in 0..<self.listData.count {
                        self.selIndex.insert(i)
                    }
                }
                else {
                    self.selIndex.removeAll()
                }
                self.updateUi()
                self.page += 1
                self.tblView.reloadData()
            }
            else {
                if res["code"].intValue == -1017 {
                    self.isPageEnd = true
                    self.listData.removeAll()
                    self.tblView.reloadData()
                }
                
                self.showErrorToast(res)            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func requestDeleteBasket() {
        guard selIndex.isEmpty == false else {
            self.showToast("상품을 선택해주세요.")
            return
        }
        var product_no = [Int]()
        for i in 0..<listData.count {
            let item = listData[i]
            if selIndex.contains(i) == true {
                product_no.append(item["product_no"].intValue)
            }
        }
        let param:[String:Any] = ["product_no" : product_no, "user_no":ShareData.ins.userNo]
        ApiManager.ins.requestDeleteBasketList(param: param) { res in
            let success = res["success"].boolValue
            if success {
                self.dataReset()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { eror in
            self.showErrorToast(eror)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCheckAll {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                for i in 0..<listData.count {
                    selIndex.insert(i)
                }
            }
            else {
                selIndex.removeAll()
            }
            updateUi()
            self.tblView.reloadData()
        }
        else if sender == btnCheckDel {
            self.requestDeleteBasket()
        }
        else if sender == btnOrder {
            
        }
    }
}

extension BasketListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BasketListCell") as? BasketListCell else {
            return UITableViewCell()
        }
        
        let item = listData[indexPath.row]
        if self.selIndex.contains(indexPath.row) == true {
            cell.configuarationData(item, true, indexPath.row)
        }
        else {
            cell.configuarationData(item, false, indexPath.row)
        }
        
        cell.completion = {(index, action) ->Void in
            if action == 100 {
                if self.selIndex.contains(index) == true {
                    self.selIndex.remove(index)
                    self.tblView.reloadData()
                }
                else {
                    self.selIndex.insert(index)
                    self.tblView.reloadData()
                }
                
                if self.selIndex.count == self.listData.count {
                    self.btnCheckAll.isSelected = true
                }
                else {
                    self.btnCheckAll.isSelected = false
                }
                self.updateUi()
            }
            else if action == 200 {
                let item = self.listData[index]
                let product_no = item["product_no"].stringValue
                let vc = OptionModifyPopupViewController.initWithData(item) { (options) in
                    var param:[String:Any] = [String:Any]()
                    
                    param["product_no"] = product_no
                    param["user_no"] = ShareData.ins.userNo
                    var arrOp = [[String:Any]]()
                    for item in options {
                        var op = [String:Any]()
                        op["color"] = item["color_code"].stringValue
                        op["size"] = item["size"].stringValue
                        op["cnt"] = item["cnt"].intValue
                        op["basket_no"] = item["basket_no"].stringValue
                        arrOp.append(op)
                    }
                    param["option"] = arrOp
                    
                    ApiManager.ins.requestModifyBasket(param: param) { res in
                        if res["success"].boolValue {
                            self.dataReset()
                        }
                    } fail: { error in
                        self.showErrorToast(error)
                    }

                }
                self.present(vc, animated: true, completion: nil)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BasketListViewController: UIScrollViewDelegate {
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
