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
        
    }
}


class StoreSelectionViewController: BaseViewController {

    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var tfSearch: CTextField!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    
    var completion:((_ item:JSON?) ->Void)?
    var listData = [JSON]()
    var type: String = "1"
    var selItem: JSON?
    var toolBar = CToolbar(barItems: [.keyboardDown])
    static func initWithType(_ type: String, _ completion:((_ item:JSON?) ->Void)?) -> StoreSelectionViewController {
        let vc = StoreSelectionViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == "1" {
            tfSearch.placeholder = "상호명을 검색해주세요."
        }
        else {
            tfSearch.placeholder = "사업자 등록번호를 검색해주세요."
        }
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        btnNext.setBackgroundImage(UIImage.color(from: RGB(203, 203, 203)), for: .disabled)
        btnNext.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .normal)
        btnNext.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
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
    }
    
    func requestSearch(_ search:String) {
        
    }
}

extension StoreSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreSelectionCell.identifier) as? StoreSelectionCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selItem = listData[indexPath.row]
        self.selItem = JSON()
        btnNext.isEnabled = true
    }
}
extension StoreSelectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isEmpty == false else {
            return false
        }
        self.view.endEditing(true)
        self.requestSearch(text)
        return true
    }
}
