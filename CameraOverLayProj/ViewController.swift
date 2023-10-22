//
//  ViewController.swift
//  CameraOverLayProj
//
//  Created by sai on 10/02/2023.
//

import UIKit

import AVFoundation



class ViewController: UIViewController {
    @IBOutlet weak var captureButtonOutlet: UIButton!
    
    var captureView: CaptureView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var photoData: Data?
    
    var cameraFrame = CGRect.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        let viewWidth = self.view.frame.width
    
        // Set required values here for Camera frame
        let cameraFrameWidth = 300.0
        let cameraFrameHeight = 200.0
        let cameraYPosition = 150.0
        
        cameraFrame = CGRect(x: (viewWidth - cameraFrameWidth)/2, y: cameraYPosition, width: cameraFrameWidth, height: cameraFrameHeight)
        
        captureView = CaptureView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        captureView.cameraFrame = cameraFrame
        self.view.addSubview(captureView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("unable to access back camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            self.stillImageOutput = AVCapturePhotoOutput()
            if self.captureSession.canAddInput(input) && self.captureSession.canAddOutput(self.stillImageOutput) {
                self.captureSession.addInput(input)
                self.captureSession.addOutput(self.stillImageOutput)
                self.setupLivePreview()
            }
        }

        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.captureSession.stopRunning()
    }

    func setupLivePreview() {
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        self.view.layer.addSublayer(self.videoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
                self.view.bringSubviewToFront(self.captureView)
                self.view.bringSubviewToFront(self.captureButtonOutlet)
            }
        }
    }

    @IBAction func captureBtnAction(_ sender: Any) {
        stillImageOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    private func cropToPreviewLayer(from originalImage: UIImage, toSizeOf rect: CGRect) -> UIImage? {
        guard let cgImage = originalImage.cgImage else { return nil }
        let outputRect = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rect)

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        let cropRect = CGRect(x: (outputRect.origin.x * width), y: (outputRect.origin.y * height), width: (outputRect.size.width * width), height: (outputRect.size.height * height))

        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: originalImage.imageOrientation)
        }

        return nil
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
  
  func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    // Flash the screen to signal that the camera took a photo.
    self.captureView.layer.opacity = 0
    UIView.animate(withDuration: 0.25) {
      self.captureView.layer.opacity = 1
    }
  }
  
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
      if let error = error {
          print("Error capturing photo: \(error)")
      }else {
          photoData = photo.fileDataRepresentation()
          guard let photoData = photoData, let image = UIImage(data: photoData)  else { return }
          let croppedImage = cropToPreviewLayer(from: image, toSizeOf: cameraFrame)
          
          guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImagePreviewViewController") as? ImagePreviewViewController else { return }
          guard let croppedImage = croppedImage else { return }
          vc.image = croppedImage //UIImage(cgImage: croppedImage)// photoData
          let button = UIBarButtonItem()
          button.title = "Take Another Image"
          self.navigationItem.backBarButtonItem = button
          self.navigationController?.pushViewController(vc, animated: true)
      }
  }
  
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
    if let error = error {
      print("Error capturing photo: \(error)")
      return
    }
    
    guard let photoData = photoData else {
      print("No photo data resource")
      return
    }
      
  }
  
}
