//
//  ClientMangerTabViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/25.
//

import UIKit

class ClientMangerTabViewController: BaseViewController {

    var tabContainer:TabContainerController!
    var confirmVc: ClientListViewController!
    var waitingVc: ClientListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "거래처 관리", nil)
        self.view.backgroundColor = UIColor.systemBackground
        self.setupTabContainer()
    }
    
    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    func setupTabContainer() {
        self.tabContainer = TabContainerController.init(nibName: "TabContainerController", bundle: nil)
        self.view.addSubview(tabContainer.view)
        if let subview = tabContainer.view {
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            subview.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            subview.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            subview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        tabContainer.delegate = self
        tabContainer.tabBarBackgroundColor = RGB(237, 237, 237)
        tabContainer.stackViewInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        
        self.confirmVc = ClientListViewController.initWithType(.comfirm)
        self.tabContainer.viewControllers.append(confirmVc)
        
        self.waitingVc = ClientListViewController.initWithType(.waiting)
        self.tabContainer.viewControllers.append(waitingVc)
        
        tabContainer.tabBarButtons.append(Utility.createTabBar(0, "거래처", false, true, false, false))
        tabContainer.tabBarButtons.append(Utility.createTabBar(1, "거래처 승인 대기중", true, false, false, false))
        tabContainer.reloadData()
        tabContainer.selectedIndex = 0
    }
}

extension ClientMangerTabViewController: TabContainerControllerDelegate {
    func tabContainer(tabContainer: TabContainerController, didSelectedIndex: Int) {
        if didSelectedIndex == 0 {
            self.confirmVc.dataReset()
        }
        else {
            self.waitingVc.dataReset()
        }
    }
}
