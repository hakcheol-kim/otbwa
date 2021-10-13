//
//  ProductHistoryMenuViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit
import SwiftyJSON

class ProductHistoryMenuViewController: BaseViewController {
    var selectedIndex: Int = 0
    
    var tabContainer: TabContainerController!
    var vcLike: ProductLikeViewController!
    var vcRecent: ProductRecentViewController!
    var vcNotify: ProductNotifyViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.decorationNaviBar(selectedIndex)
        self.setupTabContainer()
    }
    
    func decorationNaviBar(_ index: Int) {
        if index == 0 {
            CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
            CNavigationBar.drawTitle(self, "찜", nil)
            CNavigationBar.drawRight(self, self.createRightNaviBtn(), 11000, #selector(onClickedBtnActions(_:)))
        }
        else if index == 1 {
            CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
            CNavigationBar.drawTitle(self, "최근 본 상품", nil)
            CNavigationBar.drawRight(self, self.createRightNaviBtn(), 11000, #selector(onClickedBtnActions(_:)))
        }
        else {
            CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
            CNavigationBar.drawTitle(self, "알림", nil)
            self.navigationItem.rightBarButtonItems = nil
        }
    }
    
    func createRightNaviBtn() ->UIButton {
        let btn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 46, height: 44))
        btn.setImage(UIImage(named: "ico_delete"), for: .normal)
        btn.setImage(UIImage(named: "ico_close"), for: .selected)
        btn.contentHorizontalAlignment = .right
        return btn
    }
    
    func setupTabContainer() {
        self.tabContainer = TabContainerController.init(nibName: "TabContainerController", bundle: nil)
        self.view.addSubview(tabContainer.view)
        if let subview = tabContainer.view {
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
            subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            subview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        }
        
        tabContainer?.delegate = self
        tabContainer?.tabBarBackgroundColor = RGB(237, 237, 237)
        tabContainer?.stackViewInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        
        self.vcLike = ProductLikeViewController.instantiateFromStoryboard(.main)!
        self.tabContainer.viewControllers.append(vcLike)
        
        self.vcRecent = ProductRecentViewController.instantiateFromStoryboard(.main)!
        self.tabContainer.viewControllers.append(vcRecent)
        
        self.vcNotify = ProductNotifyViewController.instantiateFromStoryboard(.main)!
        self.tabContainer.viewControllers.append(vcNotify)
        
        tabContainer.tabBarButtons.append(Utility.createTabBar(0, "찜", false, true, false, false))
        tabContainer.tabBarButtons.append(Utility.createTabBar(1, "최근 본 상품", true, true, false, false))
        tabContainer.tabBarButtons.append(Utility.createTabBar(2, "알림", true, false, false, false))
        tabContainer.reloadData()
        tabContainer.selectedIndex = selectedIndex
        
        vcLike.completion = {(action) ->Void in
            self.decorationNaviBar(0)
        }
        vcRecent.completion = {(action) ->Void in
            self.decorationNaviBar(1)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == 11000 {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                if selectedIndex == 0 {
                    vcLike.type = .edit
                }
                else if selectedIndex == 1 {
                    vcRecent.type = .edit
                }
            }
            else {
                if selectedIndex == 0 {
                    vcLike.type = .normal
                }
                else if selectedIndex == 1 {
                    vcRecent.type = .normal
                }
            }
        }
    }
}

extension ProductHistoryMenuViewController: TabContainerControllerDelegate {
    func tabContainer(tabContainer: TabContainerController, didSelectedIndex: Int) {
        self.selectedIndex = didSelectedIndex
        if didSelectedIndex == 0 {
            self.decorationNaviBar(selectedIndex)
            //뷰가 생성 대기 전에 데이터 요청이 들어가는오류
            self.vcLike.dataRest()
        }
        else if didSelectedIndex == 1 {
            self.decorationNaviBar(selectedIndex)
            self.vcRecent.dataRest()
        }
        else {
            self.decorationNaviBar(selectedIndex)
            self.vcNotify.dataRest()
        }
    }
}
