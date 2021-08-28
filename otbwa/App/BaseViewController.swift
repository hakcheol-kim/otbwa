//
//  BaseViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import Photos
import Lightbox

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc public func actionNaviBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addTapGestureKeyBoardDown() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        self.view.addGestureRecognizer(tap)
    }
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    @objc func actionKeybardDown() {
        self.view.endEditing(true)
    }
    func showToast(_ message:String?, _ bottom: CGFloat = 56) {
        guard let message = message, message.isEmpty == false else {
            return
        }
        if UIApplication.shared.isKeyboardPresented {
            self.view.makeToast(message, position:.center)
        }
        else {
            self.view.makeToast(message, point: CGPoint(x: UIScreen.main.bounds.size.width/2, y: self.view.bounds.size.height - (self.view.window?.safeAreaInsets.bottom ?? 0) - bottom), title: nil, image: nil, completion: nil)
        }
    }
    
    func findBottomConstraint(_ view: UIView) -> NSLayoutConstraint? {
        var findConst:NSLayoutConstraint? = nil
        for const in view.constraints {
            if let conId = const.identifier, conId.contains("bottom") == true {
                findConst = const
                break
            }
        }
        return findConst
    }
    //키보드 노티 피케이션 핸들러
    @objc func notificationHandler(_ notification: NSNotification) {
        
        if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillHideNotification {
            
            let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
            
            let bottomConstraint = self.findBottomConstraint(self.view)
            guard let bottomCon = bottomConstraint, let conId = bottomCon.identifier else {
                return
            }
            
            var heightBtn:Float = 0.0
            let strH = conId.replacingOccurrences(of: "bottom_", with: "", options: [.caseInsensitive, .regularExpression])
            heightBtn = Float(strH) ?? 0.0
            
            if notification.name == UIResponder.keyboardWillShowNotification {
                var tabBarHeight:CGFloat = 0.0
                if self.navigationController?.tabBarController?.tabBar.isHidden == false {
                    tabBarHeight = self.navigationController?.toolbar.bounds.height ?? 0.0
                }
                
                let safeBottom:CGFloat = appDelegate.window?.safeAreaInsets.bottom ?? 0
                bottomCon.constant = heightKeyboard - safeBottom - tabBarHeight - CGFloat(heightBtn)
                UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                    self.view.layoutIfNeeded()
                })
            }
            else if notification.name == UIResponder.keyboardWillHideNotification {
                bottomCon.constant = 0
                UIView.animate(withDuration: TimeInterval(duration)) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func showPhoto(imgUrls:Array<String>) {
        if imgUrls.isEmpty == true {
            return
        }
    
        var images:[LightboxImage] = [LightboxImage]()
        for url in imgUrls {
            if let imgUrl = URL(string: url) {
                let lightbox = LightboxImage(imageURL: imgUrl)
                print(imgUrl)
                images.append(lightbox)
            }
        }
        let controller = LightboxController(images: images, startIndex: 0)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    func showSettingAlert(_ title:String?, _ message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            alert.dismiss(animated: false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "설정", style: .default, handler: { (action) in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            } else {
                alert.dismiss(animated: false, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func checkPermissionPhoto(_ soureType: UIImagePickerController.SourceType) {
        if soureType == .camera {
            PermissionsController.gloableInstance.checkPermissionAccessForCamera {
                self.displayImagePicker(soureType)
            } failureBlock: {
                self.showSettingAlert("카메라에 액세스할 수 없습니다", "액세스를 활성화하려면 설정 > 개인 정보 보호 > 카메라로 이동하여 이 앱에 대한 카메라 액세스를 켜십시오.")
            } deniedBlock: {
                self.showSettingAlert("카메라에 액세스할 수 없습니다", "액세스를 활성화하려면 설정 > 개인 정보 보호 > 카메라로 이동하여 이 앱에 대한 카메라 액세스를 켜십시오.")
            }
        }
        else if soureType == .photoLibrary {
            PermissionsController.gloableInstance.checkPermissionAccessGallery {
                self.displayImagePicker(soureType)
            } failureBlock: {
                self.showSettingAlert("카메라에 액세스할 수 없습니다", "액세스를 활성화하려면 설정 > 개인 정보 보호 > 카메라로 이동하여 이 앱에 대한 카메라 액세스를 켜십시오.")
            } deniedBlock: {
                self.showSettingAlert("캘러리를 액세스할 수 없습니다", "액세스를 활성화하려면 설정 > 개인 정보 보호 > 사진을 이동하여 이 앱에 대한 접근권한을 켜십시오.")
            }
        }
    }
    ///overried method
    func displayImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        
    }
}
