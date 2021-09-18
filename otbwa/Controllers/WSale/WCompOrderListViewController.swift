//
//  WCompOrderListViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON

class WCompOrderListCell: UITableViewCell {
    
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var btnState: CButton!
    @IBOutlet weak var lbStoreName: UILabel!
    @IBOutlet weak var svHistory: UIStackView!
    @IBOutlet weak var svHistoryContainer: UIStackView!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lbProdName: UILabel!
    @IBOutlet weak var lbTotalPrice: UILabel!
    
    var index: Int = 0
    var data:JSON!
    var completion: ((_ item:Any?, _ action:Int) ->Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectedBackgroundView = UIView()
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: true)
    }
    
    func configuraionData(_ _data: JSON, _ index:Int = 0, _ isShow:Bool = true) {
        self.data = _data
        self.index = index
        let option = data["option"].arrayValue
        let order_status = data["order_status"].stringValue
        lbDate.text = data["date"].stringValue
        lbStoreName.text = data["comp_nm"].stringValue
        lbPrice.text = data["total_price"].numberValue.toString()
        
        if order_status == "check" {
            btnState.setTitle("주문확인", for: .normal)
            btnState.backgroundColor = RGB(103, 186, 6)
        }
        else /*if order_status == "waiting"*/ {
            btnState.setTitle("주문대기", for: .normal)
            btnState.backgroundColor = RGB(255, 168, 0)
        }
        
        if option.isEmpty == false {
            lbProdName.text = option.first!["name"].stringValue
            lbTotalPrice.text = data["total_price"].numberValue.toString()
            svHistory.subviews.forEach { sub in
                sub.removeFromSuperview()
            }
            
            for item in option {
                let svcell = self.getItemCell(item)
                svHistory.addArrangedSubview(svcell)
            }
        }

        svHistoryContainer.isHidden = !isShow
        if isShow == true {
            btnMore.setTitle("숨기기 -", for: .normal)
        }
        else {
            btnMore.setTitle("자세히보기 +", for: .normal)
        }
    }
    
    func getItemCell(_ item:JSON) -> UIStackView {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        
        let color = item["color"].stringValue
        let size = item["size"].stringValue
        let cnt = item["cnt"].stringValue
        let total_price = item["total_price"].numberValue.toString()
        let price = item["price"].numberValue.toString()
        
        for i in 0..<5 {
            let lb = UILabel.init()
            lb.textColor = RGB(136, 136, 136)
            lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            sv.addArrangedSubview(lb)
            
            lb.textAlignment = .center
            if i == 0 {
                lb.textAlignment = .left
                lb.text = color
            }
            else if i == 1 {
                lb.text = size
            }
            else if  i == 2 {
                lb.text = cnt+"장"
            }
            else if i == 3 {
                lb.text = price+"원"
            }
            else {
                lb.textAlignment = .right
                lb.text = total_price+"원"
            }
            
        }
        return sv
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMore {
            self.completion?(index, 100)
        }
    }
}

class WCompOrderListViewController: BaseViewController {
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tblView: UITableView!

    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    
    var indexs = [Int]()
    var listData = [JSON]()
    var page = 1
    var canRequest = true
    var isPageEnd = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataReset()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSearch {
            tfSearch.becomeFirstResponder()
        }
    }
    
    func dataReset() {
        page = 1
        canRequest = true
        isPageEnd = false
        self.requestCompOrderList()
    }
    func addData() {
        self.requestCompOrderList()
    }
    func requestCompOrderList() {
        if isPageEnd == true || canRequest == false {
            return
        }
        canRequest = false
        var param = [String:Any]()
        param["comp_no"] = ShareData.ins.compNo
        param["p_current"] = page
        if let search = tfSearch.text, search.isEmpty == false {
            param["search"] = search
        }
        
        ApiManager.ins.requestCompOrderList(param) { res in
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
                self.tblView.reloadData()
                
                self.page += 1
            }
            else {
                self.isPageEnd = true
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
}
extension WCompOrderListViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WCompOrderListCell") as? WCompOrderListCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        if indexs.contains(indexPath.row) == true {
            cell.configuraionData(item, indexPath.row, true)
        }
        else {
            cell.configuraionData(item, indexPath.row, false)
        }
        
        cell.completion = {(item, action) ->Void in
            guard let item = item as? Int else {
                return
            }
            
            if action == 100 {
                if let index = self.indexs.firstIndex(of: item) {
                    self.indexs.remove(at: index)
                }
                else {
                    self.indexs.append(item)
                }
                self.tblView.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = WCompOrderDetailViewController.instantiateFromStoryboard(.wsale)!
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
extension WCompOrderListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.dataReset()
        return true
    }
}
