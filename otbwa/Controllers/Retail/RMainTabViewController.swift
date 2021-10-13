//
//  RMainTabViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit

class RMainTabViewController: BaseViewController {
    
    var tabContainer:TabContainerController?
    var totalProductListVc :RTotalProductViewController?
    var clientProductListVc : RPartnerProductViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabContainer()
        CNavigationBar.drawTitle(self, UIImage(named: "logo_top"), nil)
        CNavigationBar.drawLeft(self, UIImage(named: "ico_menu"), nil, TAG_NAVI_MEMU, #selector(onClickedBtnActions(_ :)))
        CNavigationBar.drawRight(self, UIImage(named: "ico_search"), nil, TAG_NAVI_SEARCH, #selector(onClickedBtnActions(_:)))
        CNavigationBar.drawRight(self, UIImage(named: "ico_cart"), nil, TAG_NAVI_CART, #selector(onClickedBtnActions(_:)))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func setupTabContainer() {
        self.tabContainer = TabContainerController.init(nibName: "TabContainerController", bundle: nil)
        self.view.addSubview(tabContainer!.view)
        if let subview = tabContainer?.view {
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            subview.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            subview.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            subview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        tabContainer?.delegate = self
        tabContainer?.tabBarBackgroundColor = RGB(237, 237, 237)
        tabContainer?.stackViewInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        
        self.totalProductListVc = RTotalProductViewController.instantiateFromStoryboard(.main)!
        self.tabContainer?.viewControllers.append(totalProductListVc!)
        self.clientProductListVc = RPartnerProductViewController.instantiateFromStoryboard(.main)!
        self.tabContainer?.viewControllers.append(clientProductListVc!)
        
        
        tabContainer?.tabBarButtons.append(Utility.createTabBar(0, "전체 신상", false, true, false, false))
        tabContainer?.tabBarButtons.append(Utility.createTabBar(0, "거래처 신상", true, false, false, false))
        
        tabContainer?.reloadData()
        tabContainer?.selectedIndex = 0
    }

    @objc func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_MEMU {
            let vc = MenuViewController.instantiateFromStoryboard(.main)!
            self.transitionPush(vc: vc, duration: 0.25, type: .fromLeft)
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == TAG_NAVI_SEARCH {
            let vc = SearchViewController.instantiateFromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == TAG_NAVI_CART {
            let vc = BasketListViewController.instantiateFromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension RMainTabViewController: TabContainerControllerDelegate {
    func tabContainer(tabContainer: TabContainerController, didSelectedIndex: Int) {
        if didSelectedIndex == 0 {
            totalProductListVc?.filters = nil;
            if let _ = totalProductListVc?.headerView {
                totalProductListVc?.reloadHeaderFilter()
            }
            totalProductListVc?.dataReset()
        }
        else {
            clientProductListVc?.filters = nil;
            if let _ = clientProductListVc?.headerView {
                clientProductListVc?.reloadHeaderFilter()
            }
            clientProductListVc?.dataReset();
        }
    }
}
