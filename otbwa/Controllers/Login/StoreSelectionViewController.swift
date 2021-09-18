//
//  StoreSelectionViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import UIKit
import SwiftyJSON

class StoreSelectionCell: UITableViewCell {
    static var identifier = "StoreSelectionCell"
    
    @IBOutlet var ivCheck: UIImageView!
    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var lbSub: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            ivCheck.image = UIImage(named: "check_on")
        }
        else {
            ivCheck.image = UIImage(named: "check_off")
        }
    }
    
    func configuratinData(_ data: JSON) {
//        let comp_tel = data["comp_tel"].stringValue
//        let comp_no = data["comp_no"].numberValue
        let comp_nm = data["comp_nm"].stringValue
        let comp_num = data["comp_num"].stringValue
        
        lbTitle.text = comp_nm
        lbSub.text = comp_num
    }
}


class StoreSelectionViewController: BaseViewController {

    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var tfSearch: CTextField!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    var page:Int = 1
    var canRequest = true;
    var isPageEnd = false
    
    var completion:((_ item:JSON?) ->Void)?
    var listData = [JSON]()
    var type: String = "name" //num
    var kind: String = "wsale" //retail
    
    var selItem: JSON?
    var toolBar = CToolbar(barItems: [.keyboardDown])
    
    class func initWithType(_ type: String, _ kind: String, _ completion:((_ item:JSON?) ->Void)?) -> StoreSelectionViewController {
        let vc = StoreSelectionViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if type == "name" {
            tfSearch.placeholder = "상호명을 검색해주세요."
        }
        else {
            tfSearch.placeholder = "사업자 등록번호를 검색해주세요."
        }
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        btnNext.setBackgroundImage(UIImage.color(from: RGB(203, 203, 203)), for: .disabled)
        btnNext.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .normal)
//        btnNext.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
        tfSearch.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnNext {
            self.completion?(selItem)
            self.dismiss(animated: true, completion: nil)
        }
        else if sender == btnClose {
            self.dismiss(animated: true, completion: nil)
        }
        else if sender == btnSearch {
            guard let text = tfSearch.text, text.isEmpty == false else {
                self.showToast("검색어를 입력해주세요.")
                return
            }
            self.view.endEditing(true)
            self.requestSearch()
        }
    }
    func dataReset() {
        self.page = 1
        self.canRequest = true
        self.isPageEnd = false
        self.requestSearch()
    }
    func addData() {
        self.requestSearch()
    }
    func requestSearch() {
        guard let search = tfSearch.text, search.isEmpty == false else {
            self.showToast("검색어를 입력해주세요.")
            return
        }
        
        guard isPageEnd == false || canRequest == false else {
            return
        }
        canRequest = true
        
        var param = [String:Any]()
        param["kind"] = kind
        param["type"] = type
        param["p_current"] = page
        param["search"] = search
        
        ApiManager.ins.requestFindCompany(param) { res in
            let success = res["success"].boolValue
            if success {
                let list = res["data"].arrayValue
                
                if list.count == 0 {
                    self.isPageEnd = true
                }
                if self.page == 1 {
                    self.listData = list
                }
                else if list.count > 0 {
                    self.listData.append(contentsOf: list)
                }
                
                if self.listData.count > 0 {
                    self.tblView.reloadData()
                }
                else {
                    self.showToast("검색된 매장정보가 없습니다.")
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
}

extension StoreSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreSelectionCell.identifier) as? StoreSelectionCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configuratinData(item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selItem = listData[indexPath.row]
        self.completion?(selItem)
        self.dismiss(animated: true, completion: nil)
    }
}
extension StoreSelectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isEmpty == false else {
            return false
        }
        self.view.endEditing(true)
        self.requestSearch()
        return true
    }

}
extension StoreSelectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            self.addData()
        }
    }
}
