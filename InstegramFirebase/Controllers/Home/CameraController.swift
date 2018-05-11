//
//  CameraController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 21/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    let dismissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        b.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return b
    }()
    
    let capturePhotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        b.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return b
    }()
    
    let switchCameraButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "switch_camera").withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(handleCameraSwitch), for: .touchUpInside)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("View did load")
        transitioningDelegate = self
        self.setupCaptureSession()
        self.setupCameraViews()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationPresentor()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationDissmissor()
    }
    
    @objc func handleDismiss(){
        log.verbose("handle dismiss")
        dismiss(animated: true, completion: nil)
    }

    @objc func handleCapturePhoto(){
        log.verbose("handle Capture photo")
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func handleCameraSwitch(){
        log.verbose("handleCameraSwitch")

        let blurView = UIVisualEffectView(frame: view.bounds)
        blurView.effect = UIBlurEffect(style: .light)
        view.addSubview(blurView)
        view.bringSubview(toFront: blurView)

        captureSession.beginConfiguration()
        let currentCameraInput = captureSession.inputs.first as! AVCaptureDeviceInput

        var cameraDevice: AVCaptureDevice?
        if currentCameraInput.device.position == .front {
            cameraDevice = self.defaultDevice(.back)
        }else {
            cameraDevice = self.defaultDevice(.front)
        }
        
        
        do{
            guard let newCameraDevice = cameraDevice else { return }
            let cameraInput = try AVCaptureDeviceInput(device: newCameraDevice)
            self.captureSession.removeInput(currentCameraInput)
            self.captureSession.addInput(cameraInput)
            
            if currentCameraInput.device.position == .front {
                UIView.transition(with: self.view, duration: 0.2, options: .transitionFlipFromLeft, animations: {
                }) { ( _ ) in
                    blurView.removeFromSuperview()
                    self.captureSession.commitConfiguration()
                }
            }else{
                UIView.transition(with: self.view, duration: 0.2, options: .transitionFlipFromRight, animations: {
                }) { ( _ ) in
                    blurView.removeFromSuperview()
                    self.captureSession.commitConfiguration()
                }
            }
            
            
            
        }catch let err {
            log.error("Failed to re-assign cameraInput", context: err)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        log.verbose("didFinishProcessingPhoto")
        guard let data = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: data)
        let previewPhotoContainerView = PreviewPhotoContainerView()
        previewPhotoContainerView.previewImageView.image = previewImage
        view.addSubview(previewPhotoContainerView)
        previewPhotoContainerView.anchor(topAnchor: view.topAnchor, bottomAnchor: view.bottomAnchor, leftAnchor: view.leftAnchor, rightAnchor: view.rightAnchor)
    }
    
    override var prefersStatusBarHidden: Bool {
        log.verbose("hide status bar")
        return true
    }

    private func setupCaptureSession() {
        //1: setup input
        let cameraDevice = defaultDevice(.back)
        
        guard let defaultDevice = cameraDevice else { return }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: defaultDevice)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
        } catch let err {
            log.error("failed to get camera input", context: err)
        }

        //2: setup outputs
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        //3: setup preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    private func defaultDevice(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: position) {
            log.verbose("use dual camera on supported devices")
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,for: AVMediaType.video, position: position) {
            log.verbose("use default back facing camera otherwise")
            return device
        } else {
            let errMessage = "All supported devices are expected to have at least one of the queried capture devices."
            log.error(errMessage)
            return nil
        }
    }
    
    private func setupCameraViews(){
        view.addSubview(dismissButton)
        view.addSubview(capturePhotoButton)
        view.addSubview(switchCameraButton)
        
        dismissButton.anchor(topAnchor: view.topAnchor, paddingTop: 16, bottomAnchor: nil, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: view.rightAnchor, paddingRight: -16, widthConstant: 40, heightConstant: 40, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        capturePhotoButton.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: view.bottomAnchor, paddingBottom: -24, leftAnchor: nil, paddingLeft: 0, rightAnchor: nil, paddingRight: 0, widthConstant: 80, heightConstant: 80, centerXAnchor: view.centerXAnchor, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        switchCameraButton.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: view.bottomAnchor, paddingBottom: -44, leftAnchor: nil, paddingLeft: 0, rightAnchor: view.rightAnchor, paddingRight: -16, widthConstant: 40, heightConstant: 40, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
    }
}
