//
//  FitImageView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/24.
//

/// 요거 만드는데 하루 걸렸네 짜증나!!!
import UIKit
import CoreGraphics

class FitImageView: UIView {
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var heightImg: NSLayoutConstraint!
    @IBOutlet weak var widthImg: NSLayoutConstraint!
    
    var shapeLayer: CAShapeLayer?
    var rectShape = CGRect.zero
    var isVertical = true
    
    var panView: UIView?
    
    var image: UIImage? = nil {
        didSet {
            guard let image = image, let superview = self.superview else {
                return
            }
            
            ivThumb.image = image
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
            
            let top = self.topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor)
            let leading = self.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor)
            let bottom = self.bottomAnchor.constraint(greaterThanOrEqualTo: superview.bottomAnchor)
            let trailing = self.trailingAnchor.constraint(greaterThanOrEqualTo: superview.trailingAnchor)
            top.priority = UILayoutPriority(750)
            top.isActive = true
            leading.priority = UILayoutPriority(750)
            leading.isActive = true
            bottom.priority = UILayoutPriority(750)
            bottom.isActive = true
            trailing.priority = UILayoutPriority(750)
            trailing.isActive = true
            
            let size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width*(320/375))

            if image.size.width > image.size.height {
                //vw:vh = iw:ih
                let vh = (image.size.height * size.width) / image.size.width
                widthImg.constant = size.width
                heightImg.constant = vh
                rectShape = CGRect(x: (size.width/2 - vh/2), y: 0, width: vh, height: vh)
                isVertical = false
            }
            else {
                //vw:vh = iw:ih
                let vw = (image.size.width * size.height) / image.size.height
                widthImg.constant = vw
                heightImg.constant = size.height
                rectShape = CGRect(x: 0, y: (size.height/2-vw/2), width: vw, height: vw)
                
                isVertical = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        
    }
    
    private func addPanGesture(_ view: UIView) {
        let pangesture = UIPanGestureRecognizer.init(target: self, action: #selector(didPan(_ :)))
        view.addGestureRecognizer(pangesture)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let shapeLayer = shapeLayer {
            shapeLayer.frame = ivThumb.bounds
            let path = UIBezierPath(rect: ivThumb.bounds)
            path.append(UIBezierPath(roundedRect: rectShape, cornerRadius: 0))
            path.close()
            shapeLayer.path = path.cgPath
        }
    }

    func createOverlay() {
        if let shapeLayer = shapeLayer  {
            shapeLayer.removeFromSuperlayer()
        }
        
        if let panView = panView {
            panView.removeFromSuperview()
        }
        shapeLayer = CAShapeLayer()
        shapeLayer?.isOpaque = false
        shapeLayer?.fillColor = UIColor.init(white: 0, alpha: 0.5).cgColor
        shapeLayer?.fillRule = .evenOdd
        ivThumb.layer.addSublayer(shapeLayer!)
        
        self.panView = UIView.init(frame: rectShape)
        self.addSubview(panView!)
        panView?.backgroundColor = UIColor.clear
        panView?.layer.borderWidth = 3
        panView?.layer.borderColor = UIColor(named: "AccentColor")!.cgColor
    
        self.addPanGesture(panView!)
        self.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        guard let targetView = gesture.view else {
            return
        }
        if gesture.state == .changed {
            let point = gesture.translation(in: targetView)
            
            var tPoint: CGPoint = CGPoint.zero
            if isVertical {
                tPoint = CGPoint(x: targetView.center.x, y: targetView.center.y + point.y)
                if tPoint.y < rectShape.height/2 {
                    tPoint = CGPoint(x: tPoint.x, y: rectShape.height/2)
                }
                else if tPoint.y > (self.bounds.height - rectShape.height/2) {
                    tPoint = CGPoint(x: tPoint.x, y: self.bounds.height - rectShape.height/2)
                }
            }
            else {
                tPoint = CGPoint(x: targetView.center.x + point.x, y: targetView.center.y)
                
                if tPoint.x < rectShape.width/2 {
                    tPoint = CGPoint(x: rectShape.width/2, y: tPoint.y)
                }
                else if tPoint.x > (self.bounds.width - rectShape.width/2) {
                    tPoint = CGPoint(x: self.bounds.width - rectShape.width/2, y: tPoint.y)
                }
            }
            gesture.setTranslation(.zero, in: targetView)
            
            targetView.center = tPoint
            rectShape = self.convert(targetView.bounds, from: targetView)
            print("== end \(rectShape)")
            self.setNeedsDisplay()
        }
        else if gesture.state == .ended {
            
        }
        else {
            
        }
    }
}
