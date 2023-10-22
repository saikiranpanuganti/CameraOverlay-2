//
//  ImagePreviewViewController.swift
//  CameraOverLayProj
//
//  Created by sai on 10/02/2023.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    @IBOutlet weak var imgRef: UIImageView!
    var image = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgRef.image = image
        self.imgRef.layer.cornerRadius = 20
    }
    
    @objc func takeAnotherImageBtnTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
