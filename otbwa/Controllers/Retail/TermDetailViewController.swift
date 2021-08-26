//
//  TermDetailViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/26.
//

import UIKit
import SwiftyJSON

enum TermType: String {
    case using = "using"
    case privacy = "privacy"
}

class TermDetailViewController: BaseViewController {
    @IBOutlet weak var textView: CTextView!
    var type: TermType = .using
    var data: JSON!
    
    static func initWithType(_ type: TermType) ->TermDetailViewController {
        let vc = TermDetailViewController.instantiateFromStoryboard(.main)!
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestTermText()
    }
    
    func requestTermText() {
        ApiManager.ins.requestTermText { res in
            if res["success"].boolValue {
                self.data = res["data"]
                self.decorationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    func decorationUi() {
        if type == .using {
            let text = data["termUse"].stringValue
            textView.text = text
        }
        else if type == .privacy {
            let text = data["infoUse"].stringValue
            textView.text = text
        }
    }
}
