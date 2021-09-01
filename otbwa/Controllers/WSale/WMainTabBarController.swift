//
//  WMainTabBarController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import UIKit

class WMainTabBarController: UITabBarController {

    let homeVc = WHomeViewController.instantiateFromStoryboard(.wsale)!
    let orderMangementVc = WCompOrderListViewController.instantiateFromStoryboard(.wsale)!
    let productRegistVc = WProductRegiestViewController.instantiateFromStoryboard(.wsale)!
    let clientTabVc = ClientMangerTabViewController.init()
    let myPaygeVc = WMyPageViewController.instantiateFromStoryboard(.wsale)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
        self.delegate = self
        CNavigationBar.drawTitle(self, UIImage(named: "logo_top"))
        
        self.viewControllers = [homeVc, orderMangementVc, productRegistVc, clientTabVc, myPaygeVc]
        
        let imgHome = UIImage(named: "ico_mypage_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgHomeSel = UIImage(named: "ico_mypage_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let imgOrder = UIImage(named: "ico_order_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgOrderSel = UIImage(named: "ico_order_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let imgProduct = UIImage(named: "ico_add_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgProductSel = UIImage(named: "ico_add_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let imgClient = UIImage(named: "ico_list_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgClientSel = UIImage(named: "ico_list_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let imgMyPage = UIImage(named: "ico_mypage_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgMyPageSel = UIImage(named: "ico_mypage_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let item1 = UITabBarItem(title: "홈", image: imgHome, selectedImage: imgHomeSel)
        let item2 = UITabBarItem(title: "주문관리", image: imgOrder, selectedImage: imgOrderSel)
        let item3 = UITabBarItem(title: "상품등록", image: imgProduct, selectedImage: imgProductSel)
        let item4 = UITabBarItem(title: "거래처", image: imgClient, selectedImage: imgClientSel)
        let item5 = UITabBarItem(title: "마이페이지", image: imgMyPage, selectedImage: imgMyPageSel)
        
        homeVc.tabBarItem = item1
        orderMangementVc.tabBarItem = item2
        productRegistVc.tabBarItem = item3
        clientTabVc.tabBarItem = item4
        myPaygeVc.tabBarItem = item5

        UITabBar.appearance().tintColor = UIColor.label
        UITabBar.appearance().barTintColor = UIColor.systemBackground
        self.hidesBottomBarWhenPushed = true
    }
}

extension WMainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let viewController = viewController as? WProductRegiestViewController {
            viewController.reloadData()
        }
    }
}
