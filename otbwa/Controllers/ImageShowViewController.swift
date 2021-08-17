//
//  ImageShowViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit
import SwiftyJSON

class ImageShowViewController: BaseViewController {
    @IBOutlet weak var heightImg: NSLayoutConstraint!
    @IBOutlet weak var ivEvent: UIImageView!
    var url: String!
    var vcTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, vcTitle, nil)
        
        
        self.view.layoutIfNeeded()
        Utility.downloadImage(url) { image, _ in
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
