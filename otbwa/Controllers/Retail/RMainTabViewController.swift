//
//  RMainTabViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit

class RMainTabViewController: BaseViewController {
    
    var tabContainer:TabContainerController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabContainer()
        CNavigationBar.drawTitle(self, UIImage(named: "logo_top"), nil)
        CNavigationBar.drawLeft(self, UIImage(named: "ico_menu"), nil, TAG_NAVI_MEMU, #selector(onClickedBtnActions(_ :)))
        CNavigationBar.drawRight(self, UIImage(named: "ico_search"), nil, TAG_NAVI_SEARCH, #selector(onClickedBtnActions(_:)))
        CNavigationBar.drawRight(self, UIImage(named: "ico_cart"), nil, TAG_NAVI_CART, #selector(onClickedBtnActions(_:)))
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
        
        let vc1 = RTotalProductViewController.instantiateFromStoryboard(.main)!
        self.tabContainer?.viewControllers.append(vc1)
        let vc2 = RPartnerProductViewController.instantiateFromStoryboard(.main)!
        self.tabContainer?.viewControllers.append(vc2)
        
        tabContainer?.tabBarButtons.append(self.createTabBar(0, "전체 신상"))
        tabContainer?.tabBarButtons.append(self.createTabBar(1, "거래처 신상"))
        
        tabContainer?.reloadData()
        tabContainer?.selectedIndex = 0
    }
    
    func createTabBar(_ index:Int, _ title: String) ->UIButton {
        let btn = UIButton.init(type: .custom)
        
        let attrNor = NSAttributedString.init(string: title, attributes: [.foregroundColor:RGB(175, 175, 175), .font:UIFont.systemFont(ofSize: 14, weight: .regular)])
        let attrSel = NSAttributedString.init(string: title, attributes: [.foregroundColor:UIColor(named: "AccentColor")!, .font:UIFont.systemFont(ofSize: 14, weight: .bold)])
        btn.setAttributedTitle(attrNor, for: .normal)
        btn.setAttributedTitle(attrSel, for: .selected)
        
        btn.setBackgroundImage(UIImage.color(from: RGB(237, 237, 237)), for: .normal)
        btn.setBackgroundImage(UIImage.color(from: UIColor.white), for: .selected)
        btn.layer.cornerRadius = 6
        if index == 0 {
            btn.layer.maskedCorners = CACornerMask.init(TL: false, TR: true, BL: false, BR: false)
        }
        else if index == 1 {
            btn.layer.maskedCorners = CACornerMask.init(TL: true, TR: false, BL: false, BR: false)
        }
        btn.clipsToBounds = true
        btn.layer.masksToBounds = true
        btn.adjustsImageWhenHighlighted = false
        return btn
    }
    
    @objc func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_MEMU {
            let vc = MenuViewController.instantiateFromStoryboard(.main)!
            vc.modalPresentationStyle = .fullScreen
            self.transitionPush(vc: vc, duration: 0.25, type: .fromLeft)
        }
        else if sender.tag == TAG_NAVI_SEARCH {
            let vc = SearchViewController.instantiateFromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == TAG_NAVI_CART {
            let vc = OrderViewController.instantiateFromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension RMainTabViewController: TabContainerControllerDelegate {
    func tabContainer(tabContainer: TabContainerController, didSelectedIndex: Int) {
        
    }
}
