//
//  ProductOrderDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit
import SwiftyJSON
class ProductOrderDetailViewController: BaseViewController {

    @IBOutlet weak var orderNumView: CView!
    @IBOutlet weak var orderMethod: UIStackView!
    @IBOutlet weak var bankInfo: UIStackView!
    @IBOutlet weak var receiveMethod: UIStackView!
    @IBOutlet weak var notiMsg: UIStackView!
    @IBOutlet weak var svProduct: UIStackView!
    @IBOutlet weak var btnState: CButton!
    @IBOutlet weak var btnCart: CButton!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var lbTotalPrice: UILabel!
    
    var passData: JSON!
    var data:JSON = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safetyView.isHidden = !isEdgePhone
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "주문 상세", nil)
        
        requestOrderDetailInfo()
    }
    func requestOrderDetailInfo() {
        let order_no = passData["building"].arrayValue[0]["order"].arrayValue[0]["order_no"].intValue
        let param:[String:Any] = ["user_no": ShareData.ins.userNo, "order_no":order_no]
        ApiManager.ins.requestOrderDetailInfo(param) { res in
            if res["success"].boolValue {
                self.data = res["data"]
                self.decorationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
    func decorationUi() {
        if let lb = orderNumView.viewWithTag(100) as? UILabel {
            lb.text = data["date"].stringValue
        }
        if let lb = orderNumView.viewWithTag(101) as? UILabel {
            let order_no = data["order_no"].stringValue
            lb.text = "주문번호 : \(order_no)"
        }
        
        //결제방법
        if let lb = orderMethod.viewWithTag(100) as? UILabel {
            let pay_way = data["pay_way"].stringValue
            lb.text = "결제 방법 : \(pay_way)"
            let lbDepositor = orderMethod.viewWithTag(101) as? UILabel
            
            if pay_way == "현장결제" {
                lbDepositor?.isHidden = true
            }
            else {
                lbDepositor?.isHidden = false
                let depositor = data["depositor"].stringValue
                lbDepositor?.text = "입금자명 : \(depositor)"
            }
        }
        
        //도매정보
//        "depositor": "",
//           "visit_tel": null,
//           "recipient": null,
//           "rcp_addr": null,
//           "recipient_tel": null,
//           "req_txt": "",
        
        //수령방법
        if let lb = receiveMethod.viewWithTag(100) as? UILabel {
            let recv_way = data["recv_way"].stringValue
            lb.text = "수령 방법 : \(recv_way)"
        }
        if let lb = receiveMethod.viewWithTag(101) as? UILabel {
            let rcp_addr = data["rcp_addr"].stringValue
            lb.text = "수령 장소 : \(rcp_addr)"
        }
        //전달 내용
        if let lb = notiMsg.viewWithTag(100) as? UILabel {
            let req_txt = data["req_txt"].stringValue
            if req_txt.isEmpty == false {
                lb.text = req_txt
            }
        }
        
        let checkYN = data["checkYN"].stringValue
        if checkYN != "waiting" {
            btnState.setTitle("주문확인", for: .normal)
            btnState.backgroundColor = RGB(103, 186, 6)
        }
        
        let order = data["order"].arrayValue
        let dict = Dictionary(grouping: order) { item -> String in
            return item["product_no"].stringValue
        }
        for sub in svProduct.subviews {
            sub.removeFromSuperview()
        }
        
        for (_, value) in dict {
            let itemView = Bundle.main.loadNibNamed("OrderDetialtemView", owner: nil, options: nil)?.first as! OrderDetialtemView
            svProduct.addArrangedSubview(itemView)
            itemView.configurationData(value)
        }
        
        var sum = 0
        for item in order {
            let total_price = item["total_price"].intValue
            sum += total_price
        }
        lbTotalPrice.text = "\(sum)".addComma()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
    
}
