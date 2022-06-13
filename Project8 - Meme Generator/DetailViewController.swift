//
//  DetailViewController.swift
//  Project8 - Meme Generator
//
//  Created by Vitali Vyucheiski on 5/27/22.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var memeName: String = ""
    var originalImage: String = ""
    var editedImage: String = ""
    var topText: String = ""
    var bottomText: String = ""
    var memeNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = memeName
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rename", style: .plain, target: self, action: #selector(changeName))
        
        let displayImagePath = getDocumentsDirectory().appendingPathComponent(editedImage)
        imageView.image = UIImage(contentsOfFile: displayImagePath.path)
    }
    
//Adding top & bottom texts
    @IBAction func topText(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        var textWasAddedBefore = false
        
        if topText != "" { textWasAddedBefore = true }
        
        let ac = UIAlertController(title: "Top Text", message: "Add/Change Top Text", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.text = self.topText
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newText = ac?.textFields?[0].text else { return }
            self!.topText = newText
            self!.textToImage(drawText: self!.topText, atPlace: 0, textWasAddedBefore: textWasAddedBefore)
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        })
        present(ac, animated: true)
    }
    
    @IBAction func bottomText(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        var textWasAddedBefore = false
        
        if bottomText != "" { textWasAddedBefore = true }
        
        let ac = UIAlertController(title: "Bottom Text", message: "Add/Change Bottom Text", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.text = self.bottomText
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newText = ac?.textFields?[0].text else { return }
            self!.bottomText = newText
            self!.textToImage(drawText: self!.bottomText, atPlace: 1, textWasAddedBefore: textWasAddedBefore)
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        })
        present(ac, animated: true)
    }

//Reseting, Sharing, Saving
    @IBAction func resetPicture(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        let originalImagePath = getDocumentsDirectory().appendingPathComponent(originalImage)
        let editedImagePath = getDocumentsDirectory().appendingPathComponent(editedImage)
        imageView.image = UIImage(contentsOfFile: originalImagePath.path)
        if let jpegData = imageView.image!.jpegData(compressionQuality: 1) {
            try? jpegData.write(to: editedImagePath)
        }
        
        topText = ""
        bottomText = ""
    }
    
    @IBAction func saveToLibrary(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let image = addWatermark()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func share(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let image = addWatermark().jpegData(compressionQuality: 0.8)
        
        let vc = UIActivityViewController(activityItems: [image!], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

//ChangingName
    @objc func changeName() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        let ac = UIAlertController(title: "Rename Your Meme", message: "", preferredStyle: .alert)
        ac.addTextField { (textField) in
            var textToDisplay = self.memeName
            if textToDisplay == "New Meme" { textToDisplay = ""}
            
            textField.text = textToDisplay
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newText = ac?.textFields?[0].text else { return }
            self!.memeName = newText
            self!.title = self!.memeName
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
        present(ac, animated: true)
    }
    
//Getting App's Directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
//Processing image to add text
    func textToImage(drawText text: String, atPlace place: Int, textWasAddedBefore: Bool ) {
        if textWasAddedBefore {
            let originalImagePath = getDocumentsDirectory().appendingPathComponent(originalImage)
            imageView.image = UIImage(contentsOfFile: originalImagePath.path)
        }
        
        let image = imageView.image!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: 120)!,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let textSize = (text as NSString).size(withAttributes: textFontAttributes)
        
        let topTextPoints = CGPoint(x: (image.size.width * 0.5) - (textSize.width / 2), y: (image.size.height * 0.15) - (textSize.height / 2))
        let bottomTextPoints = CGPoint(x: (image.size.width * 0.5) - (textSize.width / 2), y: (image.size.height * 0.85) - (textSize.height / 2))
        
        let points:[Int: CGPoint] = [0: topTextPoints, 1: bottomTextPoints]

        let rect = CGRect(origin: points[place]!, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let editedImagePath = getDocumentsDirectory().appendingPathComponent(editedImage)
        if let jpegData = newImage!.jpegData(compressionQuality: 1) {
            try? jpegData.write(to: editedImagePath)
        }
        imageView.image = UIImage(contentsOfFile: editedImagePath.path)
    }
    
//Checking for errors during saving to library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your EPIC meme has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

//Adding watermark
    func addWatermark() -> UIImage {
        let image = imageView.image!
        
        let text = "Created with MemeGenerator"
        
        let textColor = UIColor.red
        let textFont = UIFont(name: "Helvetica Bold", size: 50)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let textSize = (text as NSString).size(withAttributes: textFontAttributes)
        let point = CGPoint(x: (image.size.width * 0.7) - (textSize.width / 2), y: (image.size.height * 0.97) - (textSize.height / 2))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
//Parsing Data Back to MainVC
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("memeUpdate"),
                                        object: ["name": memeName,
                                                 "topText": topText,
                                                 "bottomText": bottomText,
                                                 "memeNumber": String(memeNumber)])
    }
    
//    func textFieldAC(fieldType: Int) -> String {
//        let title = ["Top Text", "Bottom Text", "Rename Your Meme"]
//        let message = ["Add/Change Top Text", "Add/Change Bottom Text", ""]
//        var stringToReturn: String = ""
//
//        let ac = UIAlertController(title: title[fieldType], message: message[fieldType], preferredStyle: .alert)
//        ac.addTextField()
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak ac] _ in
//            guard let newName = ac?.textFields?[0].text else { print("ERROR"); return }
//            stringToReturn = newName
//        })
//        present(ac, animated: true)
//
//        print(stringToReturn, "Return Called")
//        return stringToReturn
//    }
}
