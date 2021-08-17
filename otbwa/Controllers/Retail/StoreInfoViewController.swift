//
//  StoreInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/17.
//

import UIKit
import SwiftyJSON

class StoreInfoViewController: BaseViewController {
    var passData:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "매장 정보", nil)
        
    }
    
    
}
