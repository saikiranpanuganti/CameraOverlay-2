//
//  UiView+Exrension.swift
//  CameraOverLayProj
//
//  Created by sai on 10/02/2023.
//


import Foundation

import UIKit



extension UIView {
    func imageSnapshotCroppedToFrame(frame: CGRect?) -> UIImage? {
        let scaleFactor = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scaleFactor)
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard var image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        if let frame = frame {
            let scaledRect = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(scaleFactor, scaleFactor))
            if let imageRef = image.cgImage?.cropping(to: scaledRect) {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
}

