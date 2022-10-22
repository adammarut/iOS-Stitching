//
//  ViewController.swift
//  OpenCVApp
//
//  Created by Adam Marut on 13/10/2022.
//

import UIKit
import CoreML
import Vision
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    var locManager: CLLocationManager?
    var stitchedImage: UIImage?
    var isPanoramic: Bool = false
    var photosArray: NSMutableArray = NSMutableArray()
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var panoramicSwitch: UISwitch!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imageBox.image = nil
        titleLabel.title = "Take first photo"
        isPanoramic = panoramicSwitch.isOn
//        locManager = CLLocationManager()
//        locManager?.delegate = self
//        locManager?.requestWhenInUseAuthorization()
//        locManager?.requestAlwaysAuthorization()
        


//        let config = MLModelConfiguration()
//        config.computeUnits = .all
//        let coreMLModel = try? yolov7_tiny(configuration: config)
//        let visionModel = try? VNCoreMLModel(for: coreMLModel!.model)
//        visionModel?.inputImageFeatureName = "image"
//
//        let request = VNCoreMLRequest(model: visionModel!) { request, error in
//          if let results = request.results as? [VNRecognizedObjectObservation] {
//            /* do stuff with the observations */
//          }
//        }
//
//        // How Vision will resize and/or crop the image data.
//        request.imageCropAndScaleOption = .scaleFill
//
//        // Run the model on an image or CVPixelBuffer.
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
//                                            orientation: .up)
//        try handler.perform([request])
//
        //        let image2 = UIImage(imageLiteralResourceName: "IMG_3934")
        //        let image3 = UIImage(imageLiteralResourceName: "IMG_3935")
        //        let image4 = UIImage(imageLiteralResourceName: "IMG_3936")
        //        let image5 = UIImage(imageLiteralResourceName: "IMG_3937")
        //
        //
        //        imageBox.image = OpenCVWrapper.stitchPhotos(image2,photo2: image3)
        //        imageBox.image = OpenCVWrapper.stitchPhotos(imageBox.image!,photo2: image4)
        //        imageBox.image = OpenCVWrapper.stitchPhotos(imageBox.image!,photo2: image5)
        
    }
    
    @nonobjc func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            NEHotspotNetwork.fetchCurrent { hotspotNetwork in
                if let ssid = hotspotNetwork?.ssid {
                    print(ssid)
                }
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imageBox.image = nil
        newImageBox.image = nil
        photosArray.removeAllObjects()
        titleLabel.title = "Take first photo"
//        NEHotspotNetwork.fetchCurrent { hotspotNetwork in
//            if let ssid = hotspotNetwork?.ssid {
//                print(ssid)
//            }
//        }
    }
    
    @IBAction func resetBtn(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        }
    @IBOutlet weak var imageBox: UIImageView!
    
    
    @IBOutlet weak var newImageBox: UIImageView!
    
    
    @IBAction func savePhotoBtnClicked(_ sender: UIButton) {
        guard let inputImage = imageBox.image else { return }

        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: inputImage)
        titleLabel.title = "Image saved to gallery"

    }
    
    
    fileprivate func stitchPhotos() {
        if stitchedImage == nil{
            stitchedImage = newImageBox.image
            titleLabel.title = "Base image added"
            
        }else if(photosArray.count < 2){
            titleLabel.title = "Take next photo"
            
        }
        else{
            // let newStitchedImage = OpenCVWrapper.stitchPhotos(stitchedImage!, photo2: newImageBox.image!, panoramicWarp: isPanoramic)
            let newStitchedImage = OpenCVWrapper.stitchPhotos(photosArray as! [Any], panoramicWarp: isPanoramic)
            if newStitchedImage == nil{
                titleLabel.title = "Couldn't stitch photos"
                newImageBox.image = nil
            }
            else{
                stitchedImage = newStitchedImage
                imageBox.image = OpenCVWrapper.cropStitchedPhoto(stitchedImage!)
                titleLabel.title = "Images stiched"
            }
        }
    }
    
    @IBAction func StitchTapped(_ sender: UIButton) {
        stitchPhotos()
    }
    
    @IBAction func panoramicSwitch(_ sender: UISwitch) {
        isPanoramic = panoramicSwitch.isOn
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            newImageBox.image = image
            photosArray.add(image)

            if stitchedImage == nil{
                stitchedImage = image
                titleLabel.title = "Take next photo"
            }
            stitchPhotos()
            imagePicker.dismiss(animated: true, completion: nil)
//            guard let ciImage = CIImage(image: image) else {
//                fatalError("couldn't convert uiimage to CIImage")
//            }
        }
    }

}
class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    }
}


fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

struct PhotoWithDeviceMetadata: Codable{
    var phoneID: String
    var networkID: Int
    var wifiNetworks: [WifiNetworkInfo]
    var accelerometer: [Float]
    var gyro: [Float]
    var userID: String
    var timestamp: String
}

struct WifiNetworkInfo: Codable{
    var wifiName: String
    var sinalStrength: Float
}
