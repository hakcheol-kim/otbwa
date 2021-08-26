//
//  TermsTabViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit

class TermsTabViewController: BaseViewController {
    var tabContainer:TabContainerController!
    
    var termUsingVc: TermDetailViewController!
    var termPrivacyVc: TermDetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "이용약관 및 개인정보처리방침", nil)
        self.setupTabContainer()
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
        
        self.termUsingVc = TermDetailViewController.initWithType(.using)
        self.tabContainer.viewControllers.append(termUsingVc)
        
        self.termPrivacyVc = TermDetailViewController.initWithType(.privacy)
        self.tabContainer.viewControllers.append(termPrivacyVc)
        
        tabContainer.tabBarButtons.append(Utility.createTabBar(0, "이용약관", false, true, false, false))
        tabContainer.tabBarButtons.append(Utility.createTabBar(1, "개인정보처리방침", true, false, false, false))
        tabContainer.reloadData()
        tabContainer.selectedIndex = 0
    }
}

extension TermsTabViewController: TabContainerControllerDelegate {
    func tabContainer(tabContainer: TabContainerController, didSelectedIndex: Int) {
        if didSelectedIndex == 0 {
            
        }
        else {
            
        }
    }
}
