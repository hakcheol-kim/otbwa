//
//  EventDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit
import SwiftyJSON

class EventDetailViewController: BaseViewController {
    @IBOutlet weak var heightImg: NSLayoutConstraint!
    @IBOutlet weak var ivEvent: UIImageView!
    var data: JSON!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "이벤트", nil)
        let main_img = data["main_img"].stringValue
        
        self.view.layoutIfNeeded()
        Utility.downloadImage(main_img) { image, _ in
            guard let image = image else {
                return
            }
            self.ivEvent.image = image
            let h = (self.ivEvent.bounds.size.width * image.size.height)/image.size.width
            self.heightImg.constant = h
            self.view.layoutIfNeeded()
        }
    }
}
