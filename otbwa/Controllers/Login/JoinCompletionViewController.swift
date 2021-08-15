//
//  JoinCompletionViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import UIKit

class JoinCompletionViewController: BaseViewController {

    @IBOutlet var btnMain: CButton!
    @IBOutlet weak var safetyView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMain {
//            appDelegate.calll MainVc()
        }
    }
}
