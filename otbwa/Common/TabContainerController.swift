//
//  TabContainerController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/07.
//

import UIKit
protocol TabContainerControllerDelegate {
    func tabContainer(tabContainer: TabContainerController, didSelectedIndex:Int);
}

class TabContainerController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svMenu: UIStackView!
    @IBOutlet weak var heightScrollView: NSLayoutConstraint!
    var delegate: TabContainerControllerDelegate?
    
    ///decoration valus
    var stackViewInset: UIEdgeInsets = UIEdgeInsets.zero
    var tabBarBackgroundColor: UIColor = UIColor.systemBackground
    var heightTabBar: CGFloat = 40
    
    var tabBarButtons: [UIButton] = [UIButton]()
    var viewControllers: [UIViewController] = [UIViewController]()
    
    var selectedViewController: UIViewController?
    var selectedIndex: Int = 0 {
        didSet {
            if let btn = tabBarButtons[selectedIndex] as? UIButton {
                btn.sendActions(for: .touchUpInside)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadData() {
        guard tabBarButtons.isEmpty == false, viewControllers.isEmpty == false else {
            return
        }
        
        for subview in svMenu.subviews {
            subview.removeFromSuperview()
        }
        svMenu.isLayoutMarginsRelativeArrangement = true
        svMenu.layoutMargins = stackViewInset
        heightScrollView.constant = heightTabBar
        scrollView.backgroundColor = tabBarBackgroundColor
        
        var totalWidth: CGFloat = 0
        var widhts:[CGFloat] = [CGFloat]()
        for btn in tabBarButtons {
            svMenu.addArrangedSubview(btn)
            
            var width = btn.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: svMenu.bounds.height)).width
            width += (btn.contentEdgeInsets.left + btn.contentEdgeInsets.right)
            
            widhts.append(width)
            totalWidth += width
            btn.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
            btn.layer.cornerRadius = 6
        }
        
        if totalWidth > self.view.bounds.size.width {
            svMenu.distribution = .fill
            
            for i in 0..<tabBarButtons.count {
                let btn = tabBarButtons[i]
                let width = widhts[i]
                let con = btn.widthAnchor.constraint(equalToConstant: width)
                con.priority = UILayoutPriority(999)
                con.isActive = true
            }
        }
        else {
            svMenu.distribution = .fillEqually
        }
    }
    
    @objc func onClickedBtnActions(_ sender: UIButton) {
        scrollView.scrollRectToVisible(sender.frame, animated: true)
        for btn in tabBarButtons {
            btn.isSelected = false
        }
        sender.isSelected = true
        
        if let index = tabBarButtons.firstIndex(of: sender) {
            let viewController = self.viewControllers[index]
            self.displayViewController(viewController)
            self.delegate?.tabContainer(tabContainer: self, didSelectedIndex: index)
        }
    }
    
    func displayViewController(_ viewController: UIViewController) {
        if let selectedViewController = selectedViewController, selectedViewController != viewController {
            self.removeChildVc(selectedViewController)
        }
        self.addChildVc(viewController)
        self.selectedViewController = viewController
    }
    func removeChildVc(_ viewController:UIViewController) {
        viewController.beginAppearanceTransition(false, animated: true)
        viewController.removeFromParent()
        viewController.endAppearanceTransition()
    }
    func addChildVc(_ viewController:UIViewController) {
        self.addChild(viewController)
        viewController.beginAppearanceTransition(true, animated: true)
        self.view.addSubview(viewController.view)
        viewController.endAppearanceTransition()
        
        guard let subView = viewController.view else {
            return
        }
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: heightTabBar).isActive = true
        subView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        subView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        svMenu.bringSubviewToFront(self.view)
    }
}
