//
//  BaseNavigationController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationBar.isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(named: "AccentColor")
        self.navigationBar.shadowImage = UIImage()
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count == 1 {
            return false
        }
        return true
    }
}

//extension BaseNavigationController: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if viewController.isEqual(viewControllers.first) {
//            viewController.navigationController?.tabBarController?.tabBar.isHidden = false
//        }
//        else {
//            viewController.navigationController?.tabBarController?.tabBar.isHidden = true
//        }
//    }
//
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
////        print("==== didshow ====")
//        if viewController.isEqual(viewControllers.first) {
//            viewController.navigationController?.tabBarController?.tabBar.isHidden = false
//        }
//        else {
//            viewController.navigationController?.tabBarController?.tabBar.isHidden = true
//        }
//    }
//
//}
