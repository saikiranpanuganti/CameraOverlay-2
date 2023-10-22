//
//  CaptureView.swift
//  CameraOverLayProj
//
//  Created by sai on 10/02/2023.
//

import Foundation
import UIKit

class CaptureView: UIView {

    private let cutoutLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    let horizInset: CGFloat = 40.0
    let vertInset: CGFloat = 60.0
    let radius: CGFloat = 20
    var brdWidth: CGFloat = 2
    var cameraFrame: CGRect = CGRect.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() -> Void {
        self.backgroundColor = .clear
        layer.addSublayer(cutoutLayer)
        layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        let path = UIBezierPath(rect: bounds)
        let cp = UIBezierPath(roundedRect: cameraFrame, cornerRadius: radius)
        path.append(cp)
        path.usesEvenOddFillRule = true
        
        cutoutLayer.path = path.cgPath
        cutoutLayer.fillRule = .evenOdd
        cutoutLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        
        borderLayer.path = cp.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = brdWidth
        borderLayer.strokeColor = UIColor.white.cgColor
    }

}





