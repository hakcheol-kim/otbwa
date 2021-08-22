//
//  SearchImageViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/20.
//

import UIKit

class SearchImageViewController: BaseViewController {
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var tfSearch: CTextField!
    @IBOutlet weak var collectionVeiw: UICollectionView! {
        didSet {
            
        }
    }
    
    
    var searchImg: UIImage?
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfSearch.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(actionKeybardDown))
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnBack {
            self.navigationController?.popViewController(animated: true)
        }
        else if sender == btnPhoto {
            let vc = PhotoSelectAlertViewController.initWithCompletion { sourceType in
                self.checkPermissionPhoto(sourceType)
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    func dataReset() {
        
    }
    override func displayImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        let vc = CImagePickerController.init(sourceType, false) { origin, crop in
            guard let image = origin else {
                return
            }
            self.searchImg = image
            self.dataReset()
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func gotoSearchTextVc(_ search: String) {
        if let findVc = self.navigationController?.viewControllers.filter({ vc ->Bool in
            return (vc is SearchTextViewController || vc is SearchImageViewController)
        }).first {
            self.navigationController?.popToViewController(findVc, animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            let vc = SearchTextViewController.instantiateFromStoryboard(.main)!
            vc.search = search
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
}

extension SearchImageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isEmpty == false else {
            return false
        }
        gotoSearchTextVc(text)
        return true
    }
}

