//
//  RoomSelectedViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit

class RoomSelectedViewController: BaseViewController {
    @IBOutlet var tfRoom: CTextField!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var btnComplete: CButton!
    @IBOutlet var safetyView: UIView!
    var completion:((_ item:String) ->Void)?
    
    
    static func initWithCompletion(completion:((_ item:String) ->Void)?) ->RoomSelectedViewController {
        let vc = RoomSelectedViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGestureKeyBoardDown()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnClose {
            self.dismiss(animated: true, completion: nil)
        }
        else if sender == btnComplete {
            guard let text = tfRoom.text, text.isEmpty == false else {
                return
            }
            self.dismiss(animated: true, completion: nil)
            self.completion?(text)
        }
    }
    
}

extension RoomSelectedViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return true
    }
}
