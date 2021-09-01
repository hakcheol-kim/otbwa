//
//  SearchViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON
class SearchViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var tfSearch: CTextField!
    
    @IBOutlet weak var btnPhotoSearch: CButton!
    @IBOutlet weak var mySearchView: ShadowView!
    @IBOutlet weak var svMySearch: UIStackView!
    @IBOutlet weak var popularView: ShadowView!
    @IBOutlet weak var svPopularView: UIStackView!

    var searchList:[JSON]!
    var popularList:[JSON]!

    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        requestMySearch()
        requestPopularSearch()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnBack {
            self.navigationController?.popViewController(animated: true)
        }
        else if sender == btnPhoto || sender == btnPhotoSearch {
            let vc = ImageSelectOptionViewController.initWithCompletion { vcs, souretype in
                vcs?.dismiss(animated: true, completion: nil)
//                self.checkPermissionPhoto(souretype)
            }
            self.present(vc, animated: true, completion: nil)
        }
        else if let sender = sender as? CButton, sender.tag >= 100 && sender.tag < 200 {
            if let item = sender.data as? String {
                self.tfSearch.text = item
                
                self.view.endEditing(true)
                gotoSearchTextVc(item)
            }
            
        }
        else if let sender = sender as? CButton, sender.tag >= 200 && sender.tag < 300 {
            let item = sender.data as! String
            let param = ["search": item, "user_no" : ShareData.ins.userNo] as [String : Any]
            ApiManager.ins.requestDeleteSearched(param: param) { res in
                if res["success"].boolValue {
                    self.requestMySearch()
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if let sender = sender as? CButton, sender.tag >= 300 {
            if let item = sender.data as? String {
                self.tfSearch.text = item
                self.view.endEditing(true)
                self.gotoSearchTextVc(item)
            }
        }
    }
    
//    override func displayImagePicker(_ sourceType: UIImagePickerController.SourceType) {
//        let vc = CImagePickerController.init(sourceType, false) { origin, crop in
//            guard let image = origin else {
//                return
//            }
//            let vc = SearchImageViewController.instantiateFromStoryboard(.main)!
//            vc.searchImg = image
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        self.present(vc, animated: true, completion: nil)
//    }
    
    func requestMySearch() {
        ApiManager.ins.requestMySearchHistoryList(userNo: ShareData.ins.userNo) { res in
            if res["success"].boolValue {
                let search_list = res["data"]["search_list"].arrayValue
                if search_list.isEmpty == false {
                    self.mySearchView.isHidden = false
                    self.searchList = search_list
                    self.decoratinMySearch()
                }
                else {
                    self.mySearchView.isHidden = true
                }
            }
            else {
                self.mySearchView.isHidden = true
                self.showErrorToast(res)
            }
        } fail: { error in
            self.mySearchView.isHidden = true
            self.showErrorToast(error)
        }
    }
    func requestPopularSearch() {
        ApiManager.ins.requestPopularSearchWord { res in
            if res["success"].boolValue {
                let data = res["data"].arrayValue
                self.popularView.isHidden = false
                self.popularList = data
                self.decorationPopular()
            }
            else {
                self.popularView.isHidden = true
                self.showErrorToast(res)
            }
        } fail: { error in
            self.popularView.isHidden = true
            self.showErrorToast(error)
        }
    }

    func decoratinMySearch() {
        for subView in svMySearch.subviews {
            subView.removeFromSuperview()
        }
        
        for i in 0..<searchList.count {
            let item = searchList[i].stringValue
            let svCell = createMySearchCell(item, i)
            svMySearch.addArrangedSubview(svCell)
        }
    }
    func decorationPopular() {
        for subView in svPopularView.subviews {
            subView.removeFromSuperview()
        }
        
        for i in 0..<popularList.count {
            let item = popularList[i].stringValue
            let svCell = createPopularCell(item, i)
            svPopularView.addArrangedSubview(svCell)
        }
    }
    func createMySearchCell(_ title:String, _ index: Int) ->UIStackView {
        let svCell = UIStackView()
        svCell.axis = .horizontal
        svCell.spacing = 8
        let btnTitle = CButton(type: .custom)
        svCell.addArrangedSubview(btnTitle)
        btnTitle.setTitle(title, for: .normal)
        btnTitle.setTitleColor(UIColor.label, for: .normal)
        btnTitle.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btnTitle.contentHorizontalAlignment = .left
        btnTitle.contentEdgeInsets = UIEdgeInsets(top: 4, left: 15, bottom: 4, right: 15)
        btnTitle.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
        btnTitle.tag = 100+index
        btnTitle.data = title
        
        let btnClose = CButton(type: .custom)
        svCell.addArrangedSubview(btnClose)
        btnClose.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        btnClose.setImage(UIImage(named: "ico_sdel"), for: .normal)
        btnClose.setContentHuggingPriority(UILayoutPriority(rawValue: 255), for: .horizontal)
        btnClose.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
        btnClose.tag = 200+index
        btnClose.data = title
        return svCell
    }

    func createPopularCell(_ title:String, _ index: Int) ->UIStackView {
        let svCell = UIStackView()
        svCell.axis = .horizontal
        let btnTitle = CButton(type: .custom)
        svCell.addArrangedSubview(btnTitle)
        btnTitle.setTitleColor(UIColor.label, for: .normal)
        btnTitle.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btnTitle.contentHorizontalAlignment = .left
        btnTitle.contentEdgeInsets = UIEdgeInsets(top: 4, left: 15, bottom: 4, right: 15)
        btnTitle.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
        btnTitle.tag = 300+index
        let num = "\(index+1)"
        let reulst = "\(num) \(title)"
        let attr = NSMutableAttributedString(string: reulst)
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: NSMakeRange(0, num.count))
        attr.addAttribute(.foregroundColor, value: UIColor(named: "AccentColor")!, range: NSMakeRange(0, num.count))
        
        btnTitle.setAttributedTitle(attr, for: .normal)
        btnTitle.data = title
        
        return svCell
    }
    
    func gotoSearchTextVc(_ text:String?) {
        let vc = SearchTextViewController.instantiateFromStoryboard(.main)!
        vc.search = text
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isEmpty == false  else {
            return false
        }
        self.view.endEditing(true)
        self.gotoSearchTextVc(text)
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text, let textRange = Range(range, in: text) else {
            return false
        }
        let newText = text.replacingCharacters(in: textRange, with: string)
        
        return true
    }
}

