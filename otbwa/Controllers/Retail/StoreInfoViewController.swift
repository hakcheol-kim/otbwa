//
//  StoreInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/17.
//

import UIKit
import SwiftyJSON

class StoreInfoViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "ProductColCell", bundle: nil), forCellWithReuseIdentifier: "ProductColCell")
            collectionView.register(UINib(nibName: "StoreInfoHearderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "StoreInfoHearderView")
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")

        }
    }
    var headerView: StoreInfoHearderView!
    var passData:JSON!
    var data:JSON!
    var listData = [JSON]()
    
    var disp = "all" //"client" 거래처만
    var search = ""
    
    var page: Int = 1
    var canRequest = true
    var isPageEnd = false
    
    var toolBar = CToolbar.init(barItems: [.keyboardDown])
    var selOrder:[String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "매장 정보", nil)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 4, left: 18, bottom: 20, right: 18)
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = layout
        self.dataReset()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func dataReset() {
        page = 1
        canRequest = true
        isPageEnd = false
        self.requestStoreDetailInfo()
    }
    func addData() {
        self.requestStoreDetailInfo()
    }
    
    func requestStoreDetailInfo() {
        if isPageEnd == true {
            return
        }
        let comp_no = passData["comp_no"].intValue
        var param = [String:Any]()
        param["comp_no"] = comp_no
        param["disp"] = disp
        param["kind"] = ShareData.ins.kind.rawValue
        param["p_current"] = page
        if search.isEmpty == false {
            param["search"] = search
        }
        param["user_no"] = ShareData.ins.userNo
        param["order_type"] = "latest"

        ApiManager.ins.requestCompanyInfo(param) { res in
            if res["success"].boolValue {
                
                self.data = res["data"]
                let list = self.data["list"].arrayValue
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
                self.collectionView.reloadData()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == TAG_TOOL_KEYBOARD_DOWN {
            self.view.endEditing(true)
        }
    }
}

extension StoreInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductColCell", for: indexPath) as? ProductColCell else {
            return UICollectionViewCell()
        }
        let item = listData[indexPath.row]
        cell.configurationData(item)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StoreInfoHearderView", for: indexPath) as? StoreInfoHearderView else {
                return UICollectionReusableView()
            }
            
            self.headerView = header
            self.headerView.tfProductSearch.inputAccessoryView = toolBar
            toolBar.addTarget(self, selctor: #selector(onClickedBtnActions(_:)))
            self.headerView.tfProductSearch.delegate = self
            if let data = data, data.isEmpty == false {
                headerView.configurationData(data)
                
                if let selOrder = selOrder {
                    let title = selOrder["title"] as! String
                    headerView.tfProductOrder.text = title
                }
            }
            headerView.completion = {(action, item) ->Void in
                if action == 100 { //notice
                    let vc = ClientNoticeListController.instantiateFromStoryboard(.main)!
                    vc.comp_no = self.data["comp_no"].intValue
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if action == 101 { //거래처 신청
                    
                    let client_comp_no = self.data["comp_no"].intValue
                    let param:[String:Any] = ["comp_no": ShareData.ins.compNo, "client_comp_no" : client_comp_no]
                    
                    ApiManager.ins.requestClientApply(param) { res in
                        if res["success"].boolValue {
                            self.showToast("거래처 신청이 완료되었습니다.")
                        }
                        else {
                            self.showErrorToast(res)
                        }
                    } fail: { error in
                        self.showErrorToast(error)
                    }
                }
                else if action == 102 { //전화번호
                    guard let tel = item as? String else {
                        return
                    }
                    let scheme = "tel:\(tel)"
                    if let url = URL(string: scheme) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                else if action == 103 { //거래처만
                    guard let item = item as? String else {
                        return
                    }
                    self.disp = item
                    self.dataReset()
                }
                else if action == 104 { //최신상품
                    let list = [["order_type" : "latest", "title":"최신상품"], ["order_type" : "like", "title":"찜 카운트 최다 순"]]
                    let vc = PopupListViewController.initWithType(.normal, "선택해주세요.", list, ["title"]) { (vcs, item, action) in
                        vcs.dismiss(animated: true, completion: nil)
                        guard let item = item as? [String:Any] else {
                            return
                        }
                        self.selOrder = item
                        self.dataReset()
                    }
                    self.presentPanModal(vc)
                }
            }
            return header
        }
        else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            return footer
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((view.bounds.width - 18*2-8*2)/3.0)
        let rate = CGFloat(181/108.0)
        let height = rate*width
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //375:160 = w:h
        let h = (view.bounds.size.width * (160 + 142 + 134))/375
        return .init(width: view.bounds.width, height: h)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .init(width: view.bounds.width, height: 0.1)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
        let item = listData[indexPath.row]
        vc.passData = item
        self.navigationController?.pushViewController(vc, animated: true)
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

extension StoreInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.isEmpty == false {
            self.search = text
        }
        self.view.endEditing(true)
        self.dataReset()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in:text) else {
            return false
        }
        self.search = text.replacingCharacters(in: textRange, with: string)
        return true
    }
}
