//
//  CameraViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
import AVKit
import Mantis
import Photos
import BSImagePicker

public let maxResizeImge:CGFloat = 600

class CImagePickerController: UIViewController {
    var overlayView: CameraOverlayView? = nil
    var originImg: UIImage?
    
    var isCrop: Bool = true
    var maxCount: Int = 1
    var sourceType: UIImagePickerController.SourceType = .camera
    var isFirst = false
    var isAssets = false
    
    var completion:((_ data: Any?, _ subData:Any?) ->Void)?
    
    static func initWithSouretType(_ type:UIImagePickerController.SourceType, _ isCrop:Bool = false, _ maxCount:Int = 1, completion:((_ data: Any?, _ subData:Any?) ->Void)?) ->CImagePickerController {
        let vc = CImagePickerController.init()
        vc.isCrop = isCrop
        vc.maxCount = maxCount
        vc.sourceType = type
        vc.completion = completion
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if sourceType == .camera {
            self.view.backgroundColor = UIColor.clear
        }
        else {
            self.view.backgroundColor = UIColor.systemBackground
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navictrl = self.navigationController {
            navictrl.setNavigationBarHidden(true, animated: true)
        }
        if isFirst == false {
            isFirst = true
            self.checkPermissionPhoto(sourceType)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navictrl = self.navigationController {
            navictrl.setNavigationBarHidden(false, animated: true)
        }
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
    
    func displayImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            let imagePicker = UIImagePickerController()
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.modalTransitionStyle = .crossDissolve
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.navigationController?.setNavigationBarHidden(true, animated: false)
            imagePicker.toolbar.isHidden = true
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = false

            let scrrenRect = UIScreen.main.bounds
            overlayView = Bundle.main.loadNibNamed("CameraOverlayView", owner: nil, options: nil)?.first as? CameraOverlayView

            overlayView?.frame = scrrenRect
            overlayView?.delegate = self
            imagePicker.cameraOverlayView = overlayView

            let ratio: Float = 4.0/3.0
            let imageHeight : Float = floorf(Float(scrrenRect.width)*ratio)
            let scale: Float = Float(scrrenRect.height)/imageHeight
            let trans: Float = (Float(scrrenRect.height) - imageHeight) / 2
            let translate = CGAffineTransform(translationX: 0.0, y: CGFloat(trans))
            let final = translate.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
            imagePicker.cameraViewTransform = final
            
            self.present(imagePicker, animated: false, completion: nil)
        }
        else {
            let imagePicker = ImagePickerController()
            imagePicker.settings.selection.max = maxCount
            imagePicker.settings.theme.selectionStyle = .numbered
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
            imagePicker.settings.selection.unselectOnReachingMax = true
            
            let color = UIColor(named: "AccentColor")
            imagePicker.albumButton.tintColor = color
            imagePicker.cancelButton.tintColor = color
            imagePicker.doneButton.tintColor = color
            
            self.presentImagePicker(imagePicker, animated: true, select: { (asset) in
                print("Selected: \(asset)")
            }, deselect: { (asset) in
                print("deselect: \(asset)")
            }, cancel: { (assets) in
                print("cancel: \(assets)")
                imagePicker.dismiss(animated: false) {
                    self.popVc()
                }
            }, finish: { (assets) in
                print("Finished with selections: \(assets)")
                if self.isAssets == true {
                    self.completion?(assets, nil)
                    imagePicker.dismiss(animated: false) {
                        self.popVc()
                    }
                }
                else {
                    var images = [UIImage]()
                    let options = PHImageRequestOptions()
                     options.resizeMode = .exact
                     options.deliveryMode = .highQualityFormat
                     options.isSynchronous = true
                     options.isNetworkAccessAllowed = true
                    
                    for i in 0..<assets.count {
                        let asset = assets[i]
                        
                        PHImageManager.default().requestImage(for: asset, targetSize:CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: options) { result, _ in
                            if let result = result {
                                images.append(result)
                            }
                            if i == (assets.count - 1) {
                                self.completion?(images, nil)
                                imagePicker.dismiss(animated: false) {
                                    self.popVc()
                                }
                            }
                        }
                    }
                }
            }, completion: {
                
            })
        }
    }
    func popVc() {
        if let navigationCtr = self.navigationController {
            navigationCtr.popViewController(animated: false)
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension CImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false) {
            self.popVc()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let orgImg = info[UIImagePickerController.InfoKey.originalImage]
        
        if let orgImg = orgImg {
            self.originImg = (orgImg as! UIImage)
            
            if (self.isCrop) {
                picker.dismiss(animated: false) {
                    let vc = Mantis.cropViewController(image: orgImg as! UIImage)
                    vc.delegate = self
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: false)
                }
            }
            else {
                self.completion?(self.originImg, nil)
                picker.dismiss(animated: false) {
                    self.popVc()
                }
            }
        }
    }
}

extension CImagePickerController: CameraOverlayViewDelegate {
    func cameraOverlayViewCancelAction() {
        guard let imagePicker = self.presentedViewController as? UIImagePickerController else {
            return
        }
        imagePicker.dismiss(animated: true) {
            self.popVc()
        }
    }
    func cameraOverlayViewShotAction() {
        guard let imagePicker = self.presentedViewController as? UIImagePickerController else {
            return
        }
        imagePicker.takePicture()
    }
    func cameraOverlayViewRotationAction() {
        guard let imagePicker = self.presentedViewController as? UIImagePickerController else {
            return
        }
        if imagePicker.cameraDevice == UIImagePickerController.CameraDevice.rear {
            imagePicker.cameraDevice = .front
        }
        else {
            imagePicker.cameraDevice = .rear
        }
    }
}

extension CImagePickerController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: false) {
            let resizeImg = cropped.resized(toWidth: maxResizeImge)
            self.completion?(self.originImg, resizeImg)
            self.popVc()
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: false) {
            self.popVc()
        }
    }
}
