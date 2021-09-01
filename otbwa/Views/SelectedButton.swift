//
//  SelectedButton.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class SelectedButton: UIButton {
    var data:Any? = nil
    var selIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.decorationNormalBtn()
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius > 0 { setNeedsDisplay()}
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            if borderWidth > 0 { setNeedsDisplay()}
        }
    }
    @IBInspectable var tl: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var tr: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var bl: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var br: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var selBorderColor: UIColor = UIColor.clear {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var titleColor: UIColor = UIColor.label {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var selTitleColor: UIColor = UIColor(named: "AccentColor")! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.isSelected {
            self.layer.borderColor = selBorderColor.cgColor
            self.layer.borderWidth = borderWidth
            self.layer.cornerRadius = cornerRadius
            self.layer.maskedCorners = CACornerMask(TL: tl, TR: tr, BL: bl, BR: br)
        }
        else {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = borderWidth
            self.layer.cornerRadius = cornerRadius
            self.layer.maskedCorners = CACornerMask(TL: tl, TR: tr, BL: bl, BR: br)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                decorationSelectedBtn()
            }
            else {
                decorationNormalBtn()
            }
        }
    }

    func decorationSelectedBtn() {
        self.setTitleColor(selTitleColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!, weight: .bold)
        setNeedsDisplay()
    }
    func decorationNormalBtn() {
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!, weight: .regular)
        setNeedsDisplay()
    }
}
