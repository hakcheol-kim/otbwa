//
//  PhotoSelectAlertViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/21.
//

import UIKit

class PhotoSelectAlertViewController: UIViewController {

    @IBOutlet weak var btnAlbem: CButton!
    @IBOutlet weak var btnCamera: CButton!
    @IBOutlet weak var btnFullClose: UIButton!
    
    var completion: ((UIImagePickerController.SourceType) ->Void)?
    static func initWithCompletion(_ completion:((_ sourceType:UIImagePickerController.SourceType) ->Void)?) ->PhotoSelectAlertViewController {
        let vc = PhotoSelectAlertViewController.instantiateFromStoryboard(.main)!
        vc.completion = completion
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .coverVertical
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnAlbem {
            self.completion?(.photoLibrary)
            self.dismiss(animated: true, completion: nil)
        }
        else if sender == btnCamera {
            self.completion?(.camera)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
