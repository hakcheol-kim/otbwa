//
//  CView.swift
//  CustomViewExample
//
//  Created by 김학철 on 2020/06/25.
//  Copyright © 2020 김학철. All rights reserved.
//

import UIKit
@IBDesignable
class CView: UIView {
    var data:Any? = nil
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            if borderWidth > 0 {setNeedsDisplay()}
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            if borderColor != nil { setNeedsDisplay()}
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius > 0 { setNeedsDisplay()}
        }
    }
    
    @IBInspectable var halfCornerRadius:Bool = false {
        didSet {
            setNeedsDisplay()
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
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        clipsToBounds = true
        if borderWidth > 0 && borderColor != nil {
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = borderWidth
        }
        
        if halfCornerRadius {
            layer.cornerRadius = self.bounds.height/2
        }
        else if cornerRadius > 0 {
            layer.cornerRadius = cornerRadius
        }
        
        if (tl || tr || bl || br)  {
            layer.masksToBounds = true
            layer.maskedCorners = CACornerMask(TL: tl, TR: tr, BL: bl, BR: br)
        }
    }
}
