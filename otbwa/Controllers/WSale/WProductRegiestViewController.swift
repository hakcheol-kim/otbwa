//
//  WProductRegiestViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/27.
//

import UIKit
import SwiftyJSON

class WProductRegiestViewController: BaseViewController {
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var tfCategory: CTextField!
    @IBOutlet weak var tfProdName: CTextField!
    @IBOutlet weak var tfProdPrice: CTextField!
    @IBOutlet weak var btnArrowCategory: UIButton!
    @IBOutlet weak var btnArrowColor: UIButton!
    @IBOutlet weak var btnArrowSize: UIButton!
    
    ///
    @IBOutlet weak var imgBgView: CView!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var svImgContent: UIStackView!
    @IBOutlet weak var btnAddPhoto: CButton!
    @IBOutlet weak var btnSearch: CButton!
    
    @IBOutlet weak var svAiTags: UIStackView!
    @IBOutlet weak var tfColor: CTextField!
    @IBOutlet weak var tfSize: CTextField!
    @IBOutlet weak var tvMemo: CTextView!
    
    @IBOutlet weak var btnAiMatchingOn: SelectedButton!
    @IBOutlet weak var btnAiMatchingOff: SelectedButton!
    
    @IBOutlet weak var btnCountryKr: SelectedButton!
    @IBOutlet weak var btnCountryCn: SelectedButton!
    @IBOutlet weak var btnCountryOther: SelectedButton!
    
    @IBOutlet weak var btnPieceOn: SelectedButton!
    @IBOutlet weak var btnPieceOff: SelectedButton!
    
    @IBOutlet weak var btnAll: SelectedButton!
    @IBOutlet weak var btnClient: SelectedButton!
    @IBOutlet weak var btnSoldOut: SelectedButton!
    
    var filters: JSON!
    
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var passData: JSON!
    var data:JSON!
    var fitImgView: FitImageView!
    
    var aiTag: [JSON]!
    var selColors = [JSON]() {
        didSet {
            guard selColors.isEmpty == false else {
                return
            }
            var color = ""
            for item in selColors {
                color.append("\(item["value"].stringValue),")
            }
            color.removeLast()
            tfColor.text = color
        }
    }
    var selSizes = [JSON]() {
        didSet {
            guard selSizes.isEmpty == false else {
                return
            }
            var size = ""
            for item in selSizes {
                size.append("\(item["name"].stringValue),")
            }
            size.removeLast()
            tfSize.text = size
        }
    }
    var categoryNo: String?
    
    var images = [UIImage]() {
        didSet {
            svImgContent.subviews.forEach { subView in
                subView.removeFromSuperview()
            }
            self.view.layoutIfNeeded()
            for i in 0..<images.count {
                let image = images[i]
                let imgView = Bundle.main.loadNibNamed("ImgItemView", owner: nil, options: nil)?.first as! ImgItemView
                svImgContent.addArrangedSubview(imgView)
                
                imgView.layer.cornerRadius = 6
                imgView.clipsToBounds = true
                if i == 0 {
                    imgView.configurationData(image, i, false, true)
                    imgView.layer.borderWidth = 1
                    imgView.layer.borderColor = UIColor(named: "AccentColor")!.cgColor
                }
                else {
                    imgView.configurationData(image, i, true, false)
                }
                
                imgView.translatesAutoresizingMaskIntoConstraints = false
                imgView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            }
            
            guard let lbCnt = btnAddPhoto.viewWithTag(100) as? UILabel else {
                return
            }
            if images.count == 0 {
                lbCnt.text = "0"
            }
            else {
                lbCnt.text = "\(images.count)/10"
            }
            
        }
    }
    var cropImg: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "상품 수정")
        
        tfCategory.inputAccessoryView = toolBar
        tfProdName.inputAccessoryView = toolBar
        tfProdPrice.inputAccessoryView = toolBar
        tfColor.inputAccessoryView = toolBar
        tfSize.inputAccessoryView = toolBar
        tvMemo.inputAccessoryView = toolBar
        
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
        tvMemo.layer.cornerRadius = 6
        tvMemo.clipsToBounds = true
        self.addKeyboardNotification()
        self.view.layoutIfNeeded()
        
        self.requestFilters()
        self.initializationUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    func reloadData() {
        self.initializationUi()
    }
    func requestFilters() {
        ApiManager.ins.requestFilterList { res in
            if res["success"].boolValue {
                self.filters = res["data"]
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
   
    func initializationUi() {
      
        tfSize.text = ""
        tfColor.text = ""
        tfProdName.text = ""
        tfProdPrice.text = ""
        tvMemo.text = ""
        tfCategory.text = ""
        
        btnAiMatchingOn.isSelected = false
        btnAiMatchingOff.isSelected = false
        btnCountryKr.isSelected = false
        btnCountryCn.isSelected = false
        btnCountryOther.isSelected = false
        
        btnPieceOn.isSelected = false
        btnPieceOff.isSelected = false
        
        btnAll.isSelected = false
        btnClient.isSelected = false
        btnSoldOut.isSelected = false
        
        self.images.removeAll()
        self.reloadImageView()
    }
    
    func reloadImageView() {
        if let fitImgView = fitImgView {
            fitImgView.removeFromSuperview()
        }
        
        self.fitImgView = (Bundle.main.loadNibNamed("FitImageView", owner: nil, options: nil)?.first as! FitImageView)
        imgBgView.addSubview(fitImgView)
        self.fitImgView.delegate = self
        if images.isEmpty == false {
            fitImgView.image = images.first
            fitImgView.createOverlay()
            self.requestSearchAiImageTag()
        }
    }
    func requestSearchAiImageTag() {
        guard let cropImg = cropImg else {
            return
        }
        let param = ["img":cropImg, "type" : "reg"] as [String:Any]
        ApiManager.ins.requestSearchAiImageTag(param) { res in
            if res["success"].boolValue {
                self.aiTag = res["data"]["map"].arrayValue
                print("ai tags: \(String(describing: self.aiTag))")
                self.reloadAiTagView()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    func reloadAiTagView() {
        svAiTags.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        
        var svCellH: UIStackView?
        var i = 0
        for tag in aiTag {
            let type = tag["type"].stringValue
            if type == "color" || type == "category" {
                continue
            }
            if i % 2 == 0 {
                svCellH = UIStackView()
                svAiTags.addArrangedSubview(svCellH!)
                svCellH?.axis = .horizontal
                svCellH?.distribution = .fillEqually
                svCellH?.alignment = .top
                svCellH?.spacing = 8
            }
            
            let cell = Bundle.main.loadNibNamed("AiTagCellView", owner: nil, options: nil)?.first as! AiTagCellView
            svCellH!.addArrangedSubview(cell)
            cell.configurationData(tag)
            cell.completion = {(item, action) ->Void in
                guard let item = item as? JSON else {
                    return
                }
                print("sel tap: \(item)")
                let tag_code = item["tag_code"].stringValue
                let type = item["type"].stringValue
                
                let styles = self.filters["style"].arrayValue
                var list = [JSON]()
                
                for tmp in styles {
                    let level = tmp["level"].stringValue
                    let code = tmp["code"].stringValue
                    if type == "sense" {
                        if code.hasPrefix(tag_code) && level == "2" {
                            list.append(tmp)
                        }
                    }
                    else {
                        if code.hasPrefix(tag_code) && level == "3" {
                            list.append(tmp)
                        }
                    }
                }

                let vc = PopupListViewController.initWithType(.check, nil, list, ["value"]) { [weak self] (vcs, item, action) in
                    vcs.dismiss(animated: true, completion: nil)
                    guard let list = item as? [JSON], list.isEmpty == false else {
                        return
                    }
                    print("selected list: \(list)")
                    cell.list = list
                }
                self.presentPanModal(vc)
            }
            i += 1
        }
        
        var category = ""
        var colors = ""
        for tag in aiTag {
            let type = tag["type"].stringValue
            if type == "color" {
                colors.append("\(tag["value"].stringValue),")
            }
            else if type == "category" {
                category = "\(tag["value"].stringValue)"
                self.categoryNo = tag["code"].stringValue
            }
        }
        
        if colors.isEmpty == false {
            colors.removeLast()
        }
        
        btnAiMatchingOn.isSelected = true
        tfCategory.text = category
        tfColor.text = colors
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnAddPhoto {
            let vc = ImageSelectOptionViewController.initWithCompletion { vcs, soureType in
                vcs?.dismiss(animated: true, completion: nil)
                self.showImagePicker(soureType)
            }
            appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
        else if sender == btnArrowCategory {
            self.showCategoryPopup()
        }
        else if sender == btnArrowColor {
            self.showColorPopup()
        }
        else if sender == btnArrowSize {
            self.showSizePopup()
        }
        else if sender == btnAiMatchingOn {
            btnAiMatchingOn.isSelected = true
            btnAiMatchingOff.isSelected = false
        }
        else if sender == btnAiMatchingOff {
            btnAiMatchingOn.isSelected = false
            btnAiMatchingOff.isSelected = true
        }
        else if sender == btnCountryKr {
            btnCountryKr.isSelected = true
            btnCountryCn.isSelected = false
            btnCountryOther.isSelected = false
        }
        else if sender == btnCountryCn {
            btnCountryKr.isSelected = false
            btnCountryCn.isSelected = true
            btnCountryOther.isSelected = false
        }
        else if sender == btnCountryOther {
            btnCountryKr.isSelected = false
            btnCountryCn.isSelected = false
            btnCountryOther.isSelected = true
        }
        else if sender == btnAll {
            btnAll.isSelected = true
            btnClient.isSelected = false
            btnSoldOut.isSelected = false
        }
        else if sender == btnClient {
            btnAll.isSelected = false
            btnClient.isSelected = true
            btnSoldOut.isSelected = false
        }
        else if sender == btnSoldOut {
            btnAll.isSelected = false
            btnClient.isSelected = false
            btnSoldOut.isSelected = true
        }
        else if sender == btnPieceOn {
            btnPieceOn.isSelected = true
            btnPieceOff.isSelected = false
        }
        else if sender == btnPieceOff {
            btnPieceOn.isSelected = false
            btnPieceOff.isSelected = true
        }
        else if sender == btnSearch {
            self.requestSearchAiImageTag()
        }
        else if sender == btnOk {
            
            guard let name = tfProdName.text, name.isEmpty == false else {
                self.showToast("상품명을 입력해주세요.")
                return
            }
            guard let price = tfProdPrice.text?.getNumberString(), price.isEmpty == false else {
                self.showToast("상품가격을 입력해주세요.")
                return
            }
            guard images.isEmpty == false else {
                self.showToast("상품 이미지를 등록해주세요.")
                return
            }
            guard let color = tfColor.text, color.isEmpty == false else {
                self.showToast("상품 색상 선택해주세요.")
                return
            }
            guard let size = tfSize.text, size.isEmpty == false else {
                self.showToast("상품 사이즈를 선택해주세요.")
                return
            }
            guard let size = tfSize.text, size.isEmpty == false else {
                self.showToast("상품 사이즈를 선택해주세요.")
                return
            }
            if btnAiMatchingOn.isSelected == false && btnAiMatchingOff.isSelected == false {
                self.showToast("AI 매칭 노출 여부를 선택해주세요.")
                return
            }
            if btnCountryKr.isSelected == false && btnCountryCn.isSelected == false  && btnCountryOther.isSelected == false{
                self.showToast("제조국을 선택해주세요.")
                return
            }
            if btnPieceOn.isSelected == false && btnPieceOff.isSelected == false {
                self.showToast("낱장 판매 여부를 선택해주세요.")
                return
            }
            if btnAll.isSelected == false && btnClient.isSelected == false  && btnSoldOut.isSelected == false{
                self.showToast("공개여부를 선택해주세요.")
                return
            }
            
            var tagOrigData = [String:Any]()
            var tagAIData = [String:Any]()
            
            for item in aiTag {
                let key = item["type"].stringValue
                let value = item["code"].stringValue
                tagOrigData[key] = value
            }
            
            var userSelData = [String:Any]()
            for subView in svAiTags.subviews {
                for sub in subView.subviews {
                    if let sub = sub as? AiTagCellView,  let origin = sub.display, let list = sub.list, let item = list.first {
                        let key = origin["type"].stringValue
                        let value = item["code"].stringValue
                        userSelData[key] = value
                    }
                }
            }
            
            tagAIData = tagOrigData
            if userSelData.isEmpty == false { //유저가 선택한 데이터러 교체
                for (key, value) in userSelData {
                    tagAIData[key] = value
                }
            }
            
            if let categoryNo = categoryNo, categoryNo.isEmpty == false {
                tagAIData["category"] = categoryNo
            }
                
            if selColors.isEmpty == false, let color = selColors.first {
                tagAIData["color"] = color["code"].stringValue
            }
            
            var param = [String:Any]()
            param["comp_no"] = ShareData.ins.compNo
            param["description"] = tvMemo.text
            param["size"] = size
            param["price"] = Int(price)
            param["name"] = name
            
            var dispYN = "all"
            if btnClient.isSelected {
                dispYN = "client"
            }
            else if btnSoldOut.isSelected {
                dispYN = "soldout"
            }
            
            param["dispYN"] = dispYN
            do {
                if let jsonTagAIData = (try? JSONSerialization.data(withJSONObject: tagAIData, options: .fragmentsAllowed)), let agAiStr = String(data: jsonTagAIData, encoding: .utf8) {
                    param["tagAIData"] = agAiStr
                }
                if let jsonOriginData = (try? JSONSerialization.data(withJSONObject: tagOrigData, options: .fragmentsAllowed)), let originStr = String(data: jsonOriginData, encoding: .utf8) {
                    param["tagOrigData"] = originStr
                }
            }
            catch {
                print(error.localizedDescription)

            }
            
            let pieceYN = (btnPieceOn.isSelected) ? "Y" : "N"
            param["pieceYN"] = pieceYN
            let matchingYN = btnAiMatchingOn.isSelected ? "Y" : "N"
            param["matchingYN"] = matchingYN
            
            var made_in = "ETC"
            if btnCountryKr.isSelected {
                made_in = "KR"
            }
            else if btnCountryCn.isSelected {
                made_in = "CH"
            }
            
            param["made_in"] = made_in
            
            for i in 0..<images.count {
                let img = images[i]
                if i == 0 {
                    param["main_img"] = img
                }
                else {
                    let key = "img\(i+1)"
                    param[key] = img
                }
            }
            
            ApiManager.ins.requestRegistProductInfo(param) { res in
                print(res)
                if res["success"].boolValue {
                    self.tabBarController?.selectedIndex = 0
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
    }
    
    func showImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        let vc = CImagePickerController.initWithSouretType(sourceType, false, 10) { data in
            if let data = data as? UIImage {
                self.images.removeAll()
                self.images.append(data)
            }
            else if let data = data as? [UIImage] {
                self.images.removeAll()
                self.images.append(contentsOf: data)
            }
            self.reloadImageView()
        }
//        self.navigationController?.pushViewController(vc, animated: true)
        appDelegate.window!.rootViewController!.present(vc, animated: true, completion: nil)
    }
    
    func showCategoryPopup() {
        let vc = HashTagViewController.initWithType(.hastagOne) { items in
            guard let tags = items as? [JSON], let tag = tags.first as? JSON else {
                return
            }
            self.tfCategory.text = tag["name"].stringValue
            self.categoryNo = tag["ctgr_no"].stringValue
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func showColorPopup() {
        guard let colors = self.filters["color"].arrayValue as? [JSON] else {
            return
        }
        
        let vc = PopupListViewController.initWithType(.check, nil, colors, ["value"]) { vcs, item, action in
            vcs.dismiss(animated: true, completion: nil)
            guard let list = item as? [JSON] else {
                return
            }
            self.selColors = list
        }
        self.presentPanModal(vc)
    }
    
    func showSizePopup() {
        let sizes = self.filters["size"].arrayValue
        guard sizes.isEmpty == false else {
            return
        }
        let list = sizes.filter { item -> Bool in
            return item["level"].intValue == 3
        }
        let sortList = list.sorted { (item1, item2) -> Bool in
            let str1 = item1["name"].stringValue
            let str2 = item2["name"].stringValue
            return  str1.localizedCaseInsensitiveCompare(str2) == .orderedAscending
        }
        
        var preName:String = ""
        var uniqList = [JSON]()
        for item in sortList {
            let str = item["name"].stringValue
            if preName != str {
                uniqList.append(item)
            }
            preName = str
        }
        
        let vc = PopupListViewController.initWithType(.check, nil, uniqList, ["name"]) { vcs, item, action in
            vcs.dismiss(animated: true, completion: nil)
            guard let list = item as? [JSON] else {
                return
            }
            self.selSizes = list
        }
        self.presentPanModal(vc)
    }
}

extension WProductRegiestViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfCategory {
            showCategoryPopup()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfProdName {
            tfProdPrice.becomeFirstResponder()
        }
        else if textField == tfProdPrice {
            tfColor.becomeFirstResponder()
        }
        else if textField == tfColor {
            tfSize.becomeFirstResponder()
        }
        else if textField == tfSize {
            tvMemo.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
}

extension WProductRegiestViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
}
extension WProductRegiestViewController: FitImageViewDelegate {
    func didFinishCropImage(_ image: UIImage?) {
        if let _ = cropImg { // crop img 이미 있으면 저장만한다.
            self.cropImg = image
        }
        else {  //최초를 요청까지 함
            self.cropImg = image
            self.requestSearchAiImageTag()
        }
    }
}
