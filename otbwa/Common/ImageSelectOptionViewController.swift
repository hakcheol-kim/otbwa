//
//  ImageSelectOptionViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/21.
//

import UIKit

class ImageSelectOptionViewController: UIViewController {

    @IBOutlet weak var btnAlbem: CButton!
    @IBOutlet weak var btnCamera: CButton!
    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    var completion: ((_ vcs: UIViewController?, UIImagePickerController.SourceType) ->Void)?
    static func initWithCompletion(_ completion:((_ vcs: UIViewController?, _ sourceType:UIImagePickerController.SourceType) ->Void)?) ->ImageSelectOptionViewController {
        let vc = ImageSelectOptionViewController.instantiateFromStoryboard(.main)!
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
            self.completion?(self, .photoLibrary)
        }
        else if sender == btnCamera {
            self.completion?(self, .camera)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
