//
//  RPartnerProductViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit
import SwiftyJSON

class RPartnerProductViewController: BaseViewController {
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "ProductColCell", bundle: nil), forCellWithReuseIdentifier: "ProductColCell")
            collectionView.register(UINib(nibName: "FilterReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FilterReusableView")
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        }
    }
    var headerView: FilterReusableView!
    var listData:[JSON] = [JSON]()
    var baners:[JSON] = [JSON]()
    
    var page:Int = 1
    var canRequest = true;
    var isPageEnd = false
    
    var filters:JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView()
//        self.collectionView.layer.borderColor = UIColor.red.cgColor
//        self.collectionView.layer.borderWidth = 1
        
        var filters = [Any]()
        var item = JSON()
        item["title"] = "카테고리"
        item["selected"] = false
        filters.append(item)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("RTotalTrandy viewWillAppear")
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("RTotalTrandy viewWillDisappear")
    }
    
    func setupHeaderView() {
    
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 4, left: 18, bottom: 20, right: 18)
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func dataReset() {
        self.page = 1
        self.canRequest = true
        self.isPageEnd = false
        self.requestAllProductList()
    }
    func addData() {
        self.requestAllProductList()
    }
    func requestAllProductList() {
        if isPageEnd == true || canRequest == false {
            return
        }
        canRequest = false
        
        var param = [String:Any]()
        param["p_current"] = page
        param["user_no"] = ShareData.ins.userNo
        param["filterYN"] = "N"
        
        if let filters = filters, filters.isEmpty == false {
            param["filterYN"] = "Y"
            
            let ft_category = filters["ft_category"]
            let ft_addr = filters["ft_addr"]
            let ft_color = filters["ft_color"].arrayValue
            let ft_style = filters["ft_style"]
            let ft_amount = filters["ft_amount"]
            let ft_country = filters["ft_country"]
            
            if ft_category.isEmpty == false {
                param["ft_category"] = [ft_category["ctgr_no"].stringValue]
            }
            if ft_addr.isEmpty == false {
                param["ft_addr"] = ft_addr["ctgr_no"].intValue
            }
            if ft_color.isEmpty == false {
                var colors = [String]()
                for item in ft_color {
                    colors.append(item["code"].stringValue)
                }
                param["ft_color"] = colors
            }
            if ft_style.isEmpty == false {
                param["ft_style"] = ft_style["code"].stringValue
            }
            if ft_amount.isEmpty == false {
                param["min_price"] = ft_amount["min"].intValue
                param["max_price"] = ft_amount["max"].intValue
            }
            if ft_country.isEmpty == false {
                param["ft_country"] = ft_country["code"].stringValue
            }
        }
        
        ApiManager.ins.requestPartnerProductList(param: param) { res in
            let succes = res["success"].boolValue
            self.canRequest = true
            if succes {
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
                self.collectionView.reloadData()
                if (self.listData.count == 0) {
                    self.view.makeToast("상품정보를 가져올 수 없습니다.")
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
    
    func reloadHeaderFilter() {
        self.headerView.filters = self.filters;
        self.headerView.reloadData()
    }
}

extension RPartnerProductViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FilterReusableView.identifier, for: indexPath) as? FilterReusableView else {
                return UICollectionReusableView()
            }
            self.headerView = header
            self.headerView.banners = self.baners
            self.headerView.reloadData()
            
            self.headerView.completion = {(item: Any, action: Int) ->Void in
                if (action >= 100) && (action < 200) {
                    let index = action-100
                    let vc = FilterViewController.initWithSelIndex(index) { data in
                        self.filters = data as? JSON
                        self.headerView.filters = self.filters
                        self.dataReset()
                    }
                    appDelegate.mainNaviCtrl.pushViewController(vc, animated: true)
                }
                else if action == 200 {
                    let vc = FilterViewController.initWithSelIndex(0) { data in
                        self.filters = data as? JSON
                        self.headerView.filters = self.filters
                        self.dataReset()
                    }
                    appDelegate.mainNaviCtrl.pushViewController(vc, animated: true)
                }
                else if action == 300 { //didselected banner
                    guard let item = item as? JSON else {
                        return
                    }
                    print("selbanner : \(item)")
                    let vc = ImageShowViewController.instantiateFromStoryboard(.common)!
                    vc.vcTitle = "이벤트"
                    vc.url = item["main_img"].stringValue
                    appDelegate.mainNaviCtrl.pushViewController(vc, animated: true)
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
        let width = floor((collectionView.bounds.size.width - 18*2-8*2)/3.0)
        let rate = CGFloat(181/108.0)
        let height = rate*width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.bounds.width, height: (20 + 48 + 20 + 30 + 8))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .init(width: view.bounds.width, height: 0.1)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = ProductDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        appDelegate.mainNaviCtrl.pushViewController(vc, animated: true)
    }
}

extension RPartnerProductViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            self.addData()
        }
    }
}
