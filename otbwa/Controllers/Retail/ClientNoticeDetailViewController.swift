//
//  ClientNoticeDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/19.
//

import UIKit

class ClientNoticeDetailViewController: BaseViewController {
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var textView: CTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "공지사항", nil)
        
    }
}
