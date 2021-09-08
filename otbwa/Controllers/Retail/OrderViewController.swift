//
//  OrderViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/09/06.
//

import UIKit
import SwiftyJSON

class OrderViewController: BaseViewController {
    @IBOutlet weak var svProduct: UIStackView!
    @IBOutlet weak var lbTotalPrice: UILabel!
    @IBOutlet weak var btnDirect: UIButton!
    @IBOutlet weak var btnVisit: UIButton!
    @IBOutlet weak var btnDelivery: UIButton!
    @IBOutlet weak var svReceiveName: UIStackView!
    @IBOutlet weak var tfReceiveName: CTextField!
    @IBOutlet weak var svAddr: UIStackView!
    @IBOutlet weak var tfAddr: CTextField!
    @IBOutlet weak var btnAddrSearch: CButton!
    @IBOutlet weak var tfAddrDetail: CTextField!
    @IBOutlet weak var svReceiveContact: UIStackView!
    @IBOutlet weak var lbReceiveCotact: UILabel!
    @IBOutlet weak var tfReceiveContact: CTextField!
    @IBOutlet weak var btnPayMethodDirect: UIButton!
    @IBOutlet weak var btnPayMethodBankTransfer: UIButton!
    @IBOutlet weak var svHolderName: UIStackView!
    @IBOutlet weak var tfHolderName: CTextField!
    @IBOutlet weak var tvMsg: CTextView!
    @IBOutlet weak var btnOrder: CButton!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var svMsg: UIStackView!
    
    var listData:[JSON]!
    var toolBar = CToolbar.init(barItems: [.keyboardDown])
    var userInfo:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "주문하기")
        safetyView.isHidden = !isEdgePhone
        
        self.addTapGestureKeyBoardDown()
        
        tfReceiveName.inputAccessoryView = toolBar
        tfAddrDetail.inputAccessoryView = toolBar
        tfReceiveContact.inputAccessoryView = toolBar
        tfHolderName.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        
        btnDirect.isSelected = true
        btnPayMethodDirect.isSelected = true
        
        self.requestUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    func requestUserInfo() {
        ApiManager.ins.requestMyPageAndStoreInfo(userNo: ShareData.ins.userNo) { res in
            if res["success"].boolValue {
                self.userInfo = res["data"]
                self.decorationUi()
            }
        } fail: { error in
            
        }
    }
    func decorationUi() {
        svProduct.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        svMsg.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        var i = 0
        for item in listData {
            let itemView = Bundle.main.loadNibNamed("OrderItemView", owner: nil, options: nil)?.first as! OrderItemView
            svProduct.addArrangedSubview(itemView)
            itemView.configurationData(item)
            let name = item["name"].stringValue
            
            let sv = self.getSvMsg(name, i)
            svMsg.addArrangedSubview(sv)
            
            i += 1
        }
        var sum = 0
        for item in listData {
            let total_price = item["total_price"].intValue
            sum += total_price
        }
        lbTotalPrice.text = "\(sum)".addComma()
        
        self.reloadUi()
    }
    
    func reloadUi() {
        svReceiveName.isHidden = true
        svAddr.isHidden = true
        svReceiveContact.isHidden = true
        
        if btnVisit.isSelected {
            svReceiveContact.isHidden = false
            
            tfReceiveContact.setNeedsDisplay()
            lbReceiveCotact.text = "사업사 연락처"
            tfReceiveContact.text = ""
        }
        else if btnDelivery.isSelected {
            svReceiveName.isHidden = false
            svAddr.isHidden = false
            svReceiveContact.isHidden = false
            lbReceiveCotact.text = "수령인 연락처"
            tfReceiveContact.text = ""
            
            tfReceiveName.setNeedsDisplay()
            tfReceiveContact.setNeedsDisplay()
            tfAddr.setNeedsDisplay()
            tfAddrDetail.setNeedsDisplay()
            btnAddrSearch.setNeedsDisplay()
        }

        svHolderName.isHidden = true
        if btnPayMethodBankTransfer.isSelected {
            svHolderName.isHidden = false
            tfHolderName.setNeedsDisplay()
        }
        
        guard let userInfo = userInfo, userInfo.isEmpty == false else {
            return
        }
        if btnDelivery.isSelected {
            if tfAddr.text?.isEmpty == true {
                let address = userInfo["addr"].stringValue
                let arrAddr = address.components(separatedBy: " ")
                let detailAddr = arrAddr.last
                
                let addrMain = arrAddr.dropLast()
                var main = ""
                addrMain.forEach { str in
                    main.append(" \(str)")
                }
                tfAddr.text = main
                tfAddrDetail.text = detailAddr
            }
            if tfReceiveName.text?.isEmpty == true {
                tfReceiveName.text = userInfo["name"].stringValue
            }
        }
    }
    func getSvMsg(_ title: String, _ tag: Int) ->UIStackView {
        let sv = UIStackView()
        sv.spacing = 8
        sv.axis = .vertical
        
        let lbTitle = UILabel()
        sv.addArrangedSubview(lbTitle)
        lbTitle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbTitle.text = "전달 내용 - \(title)"
        
        let tvMsg = CTextView()
        tvMsg.placeHolderString = "주문시 전달할 내용을 작성해주세요."
        tvMsg.placeHolderColor = UIColor.placeholderText
        tvMsg.tag = 100+tag
        sv.addArrangedSubview(tvMsg)
        tvMsg.translatesAutoresizingMaskIntoConstraints = false
        tvMsg.heightAnchor.constraint(equalToConstant: 120).isActive = true
        tvMsg.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tvMsg.delegate = self
        tvMsg.cornerRadius = 6
        tvMsg.insetTop = 16
        tvMsg.insetBottom = 16
        tvMsg.insetLeft = 16
        tvMsg.insetRigth = 16
        tvMsg.inputAccessoryView = toolBar
        tvMsg.clipsToBounds = true
        
        return sv
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnDirect {
            btnDirect.isSelected = true
            btnVisit.isSelected = false
            btnDelivery.isSelected = false
            self.reloadUi()
        }
        else if sender == btnVisit {
            btnDirect.isSelected = false
            btnVisit.isSelected = true
            btnDelivery.isSelected = false
            self.reloadUi()
        }
        else if sender == btnDelivery {
            btnDirect.isSelected = false
            btnVisit.isSelected = false
            btnDelivery.isSelected = true
            self.reloadUi()
        }
        else if sender == btnPayMethodDirect {
            btnPayMethodDirect.isSelected = true
            btnPayMethodBankTransfer.isSelected = false
            self.reloadUi()
        }
        else if sender == btnPayMethodBankTransfer {
            btnPayMethodDirect.isSelected = false
            btnPayMethodBankTransfer.isSelected = true
            self.reloadUi()
        }
        else if sender == btnAddrSearch {
            let vc = WkWebViewController.initWithUrl(urlAddrSearch, "주소검색") { data in
                guard let data = data as? [String : Any] else {
                    return
                }
                print(data)
                let selAddr = JSON(data)
                if selAddr["userSelectedType"].stringValue == "R" {
                    self.tfAddr.text = selAddr["roadAddress"].stringValue
                }
                else {
                    self.tfAddr.text = selAddr["jibunAddress"].stringValue
                }
                self.tfAddrDetail.text = ""
                self.tfAddrDetail.becomeFirstResponder()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnOrder {
            var param = [String:Any]()
            var arrOption = [Any]()
            var arrOrderMsg = [Any]()
            
            var sum = 0
            for i in 0..<listData.count  {
                let item = listData[i]
                let product_no = item["product_no"].stringValue
                
                let option = item["option"].arrayValue
                
                for op in option {
                    var dict = [String:Any]()
                    dict["color"] = op["color_code"].stringValue
                    dict["cnt"] = op["cnt"].intValue
                    dict["size"] = op["size"].stringValue
                    dict["product_no"] = product_no
                    
                    arrOption.append(dict)
                }
                
                let total_price = item["total_price"].intValue
                sum += total_price
                
                var order_req = ""
                if let tvMsg = svMsg.viewWithTag(100+i) as? CTextView, let msg = tvMsg.text, msg.isEmpty == false {
                    order_req = msg
                }
                let msgParam:[String:Any] = ["product_no": product_no, "order_req": order_req]
                arrOrderMsg.append(msgParam)
            }
            
            param["user_no"] = ShareData.ins.userNo
            param["option"] = arrOption
            param["order"] = arrOrderMsg
            param["receive_way"] = "pickup"
            param["total_price"] = sum
            
//            let phone = userInfo["phone"].stringValue
//            let name = userInfo["name"].stringValue
//            let address = userInfo["addr"].stringValue
//            param["recipient_tel"] = phone
//            param["visit_tel"] = phone
//            param["recipient"] = name
//            param["depositor"] = name
//            param["address"] = address
            
            if btnVisit.isSelected {
                param["receive_way"] = "visit"
                if let tel = tfReceiveContact.text, tel.isEmpty == false {
                    param["visit_tel"] = tel
                }
            }
            else if btnDelivery.isSelected {
                param["receive_way"] = "delivery"
                if let name = tfReceiveName.text, name.isEmpty == false {
                    param["recipient"] = name
                }
                
                if let addr = tfAddr.text, addr.isEmpty == false {
                    var address = ""
                    address = addr
                    if let detailAddr = tfAddrDetail.text, detailAddr.isEmpty == false {
                        address.append(" \(detailAddr)")
                    }
                    param["address"] = address
                }
                
                if let receivePhone = tfReceiveContact.text, receivePhone.isEmpty == false {
                    param["recipient_tel"] = receivePhone
                }
            }
            
            param["pay_way"] = "direct"
            if btnPayMethodBankTransfer.isSelected {
                param["pay_way"] = "transfer"
                if let holderName = tfHolderName.text, holderName.isEmpty == false {
                    param["depositor"] = holderName
                }
            }
            
            ApiManager.ins.requestProductsOrder(param) { res in
                if res["success"].boolValue {
                    appDelegate.window?.makeToast("주문이 완료되었습니다.")
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
    }
}
extension OrderViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
}

