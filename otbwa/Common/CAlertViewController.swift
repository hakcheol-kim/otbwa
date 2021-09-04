//
//  CAlertViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/19.
//

import UIKit

enum CAletType {
    case alert, custom
}

enum CAletBtnStyle {
    case ok, cancel, normal
}

typealias CAletClosure = (_ vcs:CAlertViewController, _ action:Int) ->Void

class CAlertViewController: UIViewController {
    @IBOutlet weak var shadowView: CView!
    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var btnBgView: UIView!
    @IBOutlet weak var svBtn: UIStackView!
    
    var lbMsgTextAligment: NSTextAlignment = .center
    var isBackGroundTouchClose: Bool = true
    
    var fontMsg: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    var fontTitle: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    
    var type: CAletType = .alert
    var aletTitle: Any?
    var message: Any?
    var completion: CAletClosure?
    var actions:[CAletBtnStyle]?
    
    var arrBtn = [UIButton]()
    
    convenience init(type:CAletType, title:Any? = nil, message:Any?, actions:[CAletBtnStyle]? = nil, completion:CAletClosure?) {
        self.init()
        self.type = type
        self.aletTitle = title
        self.message = message
        self.actions = actions
        self.completion = completion
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    class func show(type:CAletType, title:Any? = nil, message:Any?, actions:[CAletBtnStyle]? = nil, completion:CAletClosure?) {
        let calert = CAlertViewController.init(type: type, title: title, message: message, actions: actions, completion: completion)
        appDelegate.window?.rootViewController?.present(calert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurationUi()
    }

    func configurationUi() {
        self.view.layoutIfNeeded()
        
        for sub in svBtn.subviews {
            sub.removeFromSuperview()
        }
        if let actions = actions {
            var index = 0
            for action in actions {
                let btn = self.getButton(action)
                btn.tag = 100 + index
                self.arrBtn.append(btn)
                index += 1
            }
        }
        btnBgView.isHidden = arrBtn.isEmpty
        
        for btn in arrBtn {
            svBtn.addArrangedSubview(btn)
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        
        if let message = message as? String {
            lbMsg.text = message
        }
        else if let message = message as? NSAttributedString {
            lbMsg.attributedText = message
        }
    }
    
    func addAction(_ btnStyle:CAletBtnStyle, _ title:Any? = nil) {
        let btn = self.getButton(btnStyle, title)
        btn.tag = 100 + arrBtn.count
        self.arrBtn.append(btn)
    }
    func getButton(_ type: CAletBtnStyle, _ title: Any? = nil) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        if type == .ok {
            btn.setTitleColor(UIColor(named: "AccentColor")!, for: .normal)
        }
        else if type == .cancel {
            btn.setTitleColor(RGB(136, 136, 136), for: .normal)
        }
        else {
            btn.setTitleColor(UIColor.label, for: .normal)
        }
        
        if let title = title as? String {
            btn.setTitle(title, for: .normal)
        }
        else if let title = title as? NSAttributedString {
            btn.setAttributedTitle(title, for: .normal)
        }
        else {
            if type == .ok {
                btn.setTitle("확인", for: .normal)
            }
            else if type == .cancel {
                btn.setTitle("취소", for: .normal)
            }
        }
        btn.backgroundColor = UIColor.white
        return btn
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnFullClose {
            self.dismiss(animated: false, completion: nil)
        }
        else if sender.tag >= 100 && sender.tag < 200 { //ok, cancel
            let index = sender.tag - 100
            self.completion?(self, index)
        }
    }
}
