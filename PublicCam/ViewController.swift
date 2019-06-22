//
//  ViewController.swift
//  TestingPicture
//
//  Created by Achsuthan Mahendran on 22/6/19.
//  Copyright © 2019 Achsuthan Mahendran. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var btClose: UIButton!
    @IBOutlet weak var btFront: UIButton!
    @IBOutlet weak var btBack: UIButton!
    
    @IBOutlet weak var imgFront: UIImageView!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var output = AVCaptureStillImageOutput()
    var qrCodeFrameView: UIView?
    var timmer: Int = 5 * 60
    var runningTime: Timer?
    var isFront: Bool = false
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewImage.alpha = 0
        self.camSetUp()
        self.setUp()
    }
    
    func setUp(){
        self.btClose.addTarget(self, action: #selector(self.btClose(_:)), for: .touchUpInside)
        self.timeSlider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        self.btBack.addTarget(self, action: #selector(self.btBack(_:)), for: .touchUpInside)
        self.btFront.addTarget(self, action: #selector(self.btFront(_:)), for: .touchUpInside)
        
        self.imgFront.image = UIImage(named: "icon_radio")
        self.imgFront.image = self.imgFront.image?.withRenderingMode(.alwaysTemplate)
        self.imgFront.tintColor = self.hexStringToUIColor(hex: "#122D3E")
        
        self.imgBack.image = UIImage(named: "icon_radio_selected")
        self.imgBack.image = self.imgBack.image?.withRenderingMode(.alwaysTemplate)
        self.imgBack.tintColor = self.hexStringToUIColor(hex: "#099E44")
    }
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func setUptimer(){
        if let _ = self.runningTime {
            self.runningTime?.invalidate()
        }
        
        self.runningTime = Timer.scheduledTimer(timeInterval: TimeInterval(self.timmer), target: self, selector: #selector(self.timerCalled(_:)), userInfo: nil, repeats: true)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.timmer = currentValue * 60
        self.lblTime.text = "\(currentValue) mins"
        self.setUptimer()
    }
    
    @IBAction func btFront(_ sender: Any) {
        self.isFront = true
        self.changeCamPostion()
    }
    @IBAction func btBack(_ sender: Any) {
        self.isFront = false
        self.changeCamPostion()
    }
    
    func changeCamPostion(){
        if let session: AVCaptureSession = self.captureSession {
            let currentCameraInput: AVCaptureInput = session.inputs[0]
            session.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice
            newCamera = AVCaptureDevice.default(for: AVMediaType.video)!
            
            if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
                UIView.transition(with: self.viewCamera, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                    newCamera = self.cameraWithPosition(.front)!
                }, completion: nil)
            } else {
                UIView.transition(with: self.viewCamera, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    newCamera = self.cameraWithPosition(.back)!
                }, completion: nil)
            }
            do {
                try self.captureSession.addInput(AVCaptureDeviceInput(device: newCamera))
                if self.isFront {
                    self.imgFront.image = UIImage(named: "icon_radio_selected")
                    self.imgFront.image = self.imgFront.image?.withRenderingMode(.alwaysTemplate)
                    self.imgFront.tintColor = self.hexStringToUIColor(hex: "#099E44")
                    
                    
                    self.imgBack.image = UIImage(named: "icon_radio")
                    self.imgBack.image = self.imgBack.image?.withRenderingMode(.alwaysTemplate)
                    self.imgBack.tintColor = self.hexStringToUIColor(hex: "#122D3E")
                }
                else {
                    self.imgFront.image = UIImage(named: "icon_radio")
                    self.imgFront.image = self.imgFront.image?.withRenderingMode(.alwaysTemplate)
                    self.imgFront.tintColor = self.hexStringToUIColor(hex: "#122D3E")
                    
                    self.imgBack.image = UIImage(named: "icon_radio_selected")
                    self.imgBack.image = self.imgBack.image?.withRenderingMode(.alwaysTemplate)
                    self.imgBack.tintColor = self.hexStringToUIColor(hex: "#099E44")
                }
            }
            catch {
                print("error: \(error.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func btClose(_: Any){
        var alert = UIAlertController(title: "", message: "This feature is not available", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func camSetUp(){
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
        case .authorized:
            DispatchQueue.main.async {
                self.popCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if (granted){
                    DispatchQueue.main.async {
                        self.popCamera()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.camDenied()
                    }
                }
            }
            break
            
        case .denied:
            DispatchQueue.main.async {
                self.camDenied()
            }
            break
        case .restricted:
            let alert = UIAlertController(title: "Restricted",
                                          message: "You've been restricted from using the camera on this device. Without camera access this feature won't work. Please contact the device owner so they can give you access.",
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func popCamera(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return }
        
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self as! AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            self.viewImage.alpha = 1
            captureSession.addOutput(output)
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = self.viewCamera.layer.bounds
        self.viewCamera.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        output.outputSettings = [ AVVideoCodecKey: AVVideoCodecJPEG ]
        self.setUptimer()
    }
    
    @objc func timerCalled(_ timer: Timer) {
        print("Timmer called")
        capturePhoto()
    }
    
    func camDenied(){
        DispatchQueue.main.async{
            var alertText = "It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Turn the Camera on.\n\n5. Open this app and try again."
            
            var alertButton = "OK"
            var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)
            
            if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                alertText = "It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Camera on.\n\n3. Open this app and try again."
                alertButton = "Go"
                goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
            }
            let alert = UIAlertController(title: "Error", message: alertText, preferredStyle: .alert)
            alert.addAction(goAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func capturePhoto() {
        guard let connection = self.output.connection(with: AVMediaType.video) else {
            print("Something wrong")
            return
            
        }
        connection.videoOrientation = .portrait
        
        output.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
            guard sampleBuffer != nil && error == nil else {
                print("error \(error)")
                return
                
            }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
            guard let image = UIImage(data: imageData!) else { return }
            print("image \(image)")
            self.imgView.image = image
            self.imgView.clipsToBounds = true
            self.imgView.contentMode = UIView.ContentMode.scaleAspectFill
            
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                
            }
        }
    }
    
}



