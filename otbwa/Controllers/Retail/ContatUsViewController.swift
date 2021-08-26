//
//  ContatUsViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import MessageUI
class ContatUsViewController: BaseViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var btnTel: CButton!
    @IBOutlet weak var btnKakao: CButton!
    @IBOutlet weak var btnEmail: CButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "고객센터", nil)
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnTel {
            let url = "tel://02-1234-5668"
            appDelegate.openUrl(url) { success in
                
            }
        }
        else if sender == btnKakao {
            let url = "https://pf.kakao.com/_sbxexfK"
            appDelegate.openUrl(url, completion: nil)
        }
        else if sender == btnEmail {
            //"contact@otbwa.com"
            self.sendEmail()
        }
    }
    func sendEmail() {
        let email = "contact@otbwa.com"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody("<p>'옷봐' 관리자님 안녕하세요.</p>", isHTML: true)

            present(mail, animated: true)
        }
        else {
            let url = "mailto:\(email)"
            appDelegate.openUrl(url, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
