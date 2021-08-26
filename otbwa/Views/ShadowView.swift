//
//  ShadowView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/16.
//

import UIKit

class ShadowView: UIView {
        var data:Any? = nil
        
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
        
        @IBInspectable var sdColor: UIColor? {
            didSet {
                if let _ = sdColor {
                    setNeedsDisplay()
                }
            }
        }
        @IBInspectable var sdOffset:CGSize = CGSize.zero {
            didSet {
                if sdOffset.width > 0 || sdOffset.height > 0 { setNeedsDisplay()}
            }
        }
        @IBInspectable var sdRadius: CGFloat = 0.0 {
            didSet {
                if sdRadius > 0 {setNeedsDisplay()}
            }
        }
        @IBInspectable var sdOpacity: Float = 0.0 {
            didSet {
                if sdOpacity > 0 { setNeedsDisplay()}
            }
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            layer.masksToBounds = false
            if halfCornerRadius {
                layer.cornerRadius = self.bounds.height/2
            }
            else if cornerRadius > 0 {
                layer.cornerRadius = cornerRadius
            }
            
            if tl || tr || bl || br  {
                layer.maskedCorners = CACornerMask(TL: tl, TR: tr, BL: bl, BR: br)
            }
            
            if let sColor = sdColor {
                layer.shadowOffset = sdOffset
                layer.shadowColor = sColor.cgColor
                layer.shadowRadius = sdRadius
                layer.shadowOpacity = sdOpacity
                self.backgroundColor = UIColor.clear
//                let backgroundCGColor = backgroundColor?.cgColor
//                backgroundColor = nil
//                layer.backgroundColor = backgroundCGColor
            }
        }
    }
