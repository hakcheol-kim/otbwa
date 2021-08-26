//
//  ClientListViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit
import SwiftyJSON

enum ClientManageType: String {
    case comfirm = "client"
    case waiting = "waiting"
}

class ClientListCell: UITableViewCell {
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var btnCancel: CButton!
    @IBOutlet weak var btnDel: CButton!
    
    var type: ClientManageType = .comfirm
    
    var data: JSON!
    var completion:((_ item: JSON?, _ action: Int) -> Void)?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configuraionData(_ data:JSON, _ type: ClientManageType) {
        self.data = data
        self.type = type
        
        let addr = data["addr"].stringValue
        let img = data["img"].stringValue
        let name = data["name"].stringValue
        ivThumb.layer.cornerRadius = 6
        
        lbTitle.text = name
        lbSubTitle.text = addr
        ivThumb.image = nil
        if img.isEmpty == false {
            ivThumb.setImageCache(img)
        }
        
        if type == .comfirm {
            btnCancel.isHidden = true
            btnDel.setTitle("거래처 삭제", for: .normal)
        }
        else {
            btnCancel.isHidden = false
            btnDel.setTitle("승인 대기중", for: .normal)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCancel {
            self.completion?(self.data, 100)    //거래처 취소
        }
        else if sender == btnDel {
            if self.type == .comfirm {
                self.completion?(self.data, 200) // 거래처 삭제
            }
            else {
                self.completion?(self.data, 300)  //거래처 승인 대기
            }
        }
    }
}

class ClientListViewController: BaseViewController {
    
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var listData = [JSON]()
    var type: ClientManageType = .comfirm
    
    var page = 1
    var canRequest = true
    var isPageEnd = false
    
    static func initWithType(_ type: ClientManageType) ->ClientListViewController {
        let vc = ClientListViewController.instantiateFromStoryboard(.main)!
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        
        self.tblView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func dataReset() {
        page = 1
        canRequest = true
        isPageEnd = false
        self.requestSearchClients()
    }
    func addData() {
        self.requestSearchClients()
    }
    
    func requestSearchClients() {
        if isPageEnd == true {
            return
        }
        
        var param = [String:Any]()
        param["comp_no"] = ShareData.ins.compNo
        param["kind"] = ShareData.ins.kind.rawValue
        param["p_current"] = page
        param["type"] = type.rawValue
        if let search = tfSearch.text, search.isEmpty == false {
            param["search"] = search
        }
        
        ApiManager.ins.requestSearchClients(param) { res in
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
    
    @IBAction func onClieckedBtnActions(_ sender: UIButton) {
        if sender == btnSearch {
            tfSearch.becomeFirstResponder()
        }
    }
    
    func requestClientMangement(_ param: [String:Any]) {
        ApiManager.ins.requestClientMangement(param) { res in
            self.dataReset()
        } fail: { error in
            self.showErrorToast(error)
        }

    }
}

extension ClientListViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientListCell") as? ClientListCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configuraionData(item, self.type)
        cell.completion = {(item, action) ->Void in
            guard let item = item else {
                return
            }
            
            if action == 100 { // 거래처 취소
                var param = [String:Any]()
                param["client_no"] = item["client_key"].stringValue
                param["comp_no"] = item["comp_no"].stringValue
                param["kind"] = ShareData.ins.kind.rawValue
                param["fn_value"] = "cancel"
                param["type"] = self.type.rawValue
                self.requestClientMangement(param)
            }
            else if action == 200 {  //거래처 삭제
                var param = [String:Any]()
                param["client_no"] = item["client_key"].stringValue
                param["comp_no"] = item["comp_no"].stringValue
                param["kind"] = ShareData.ins.kind.rawValue
                param["fn_value"] = "stop"
                param["type"] = self.type.rawValue
                self.requestClientMangement(param)
            }
            else if action == 300 {  //거래처 승인대기
                
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
extension ClientListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.dataReset()
        return true
    }
}
