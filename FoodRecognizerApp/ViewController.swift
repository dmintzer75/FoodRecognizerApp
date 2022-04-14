//
//  ViewController.swift
//  FoodRecognizerApp
//
//  Created by Dario Mintzer on 14/04/2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Image couldn't convert to CIImage")
            }
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true)
        
        
    }
    
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else  {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier.components(separatedBy: ",")[0]
                + " " + String(format: "%.2f", firstResult.confidence )
                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
        //        // Create an instance of the image classifier's wrapper class.
        //        guard let imageClassifier = try? MobileNetV2(configuration: MLModelConfiguration()) else {
        //            fatalError("App failed to create an image classifier model instance.")
        //        }
        //
        //        // Get the underlying model instance.
        //        let imageClassifierModel = imageClassifier.model
        //
        //        // Create a Vision instance using the image classifier's model instance.
        //        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
        //            fatalError("App failed to create a `VNCoreMLModel` instance.")
        //        }
        //
        //        let imageClassificationRequest = VNCoreMLRequest(model: model,                                                    completionHandler: visionRequestHandler)
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

