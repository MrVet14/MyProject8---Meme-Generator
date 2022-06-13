//
//  ViewController.swift
//  Project8 - Meme Generator
//
//  Created by Vitali Vyucheiski on 5/27/22.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var memes = [Meme]()
    var observer: NSObjectProtocol?
    var VCLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meme Generator"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewMeme))
        
        save()
        
        VCLoaded = true
        
        //Parsing data from detailVC
        DispatchQueue.main.async {
            self.observer = NotificationCenter.default.addObserver(forName: Notification.Name("memeUpdate"), object: nil, queue: .main, using: { notification in
                
                guard let object = notification.object as? [String: String] else { return }
                
                guard let memeName = object["name"] else { return }
                guard let topText = object["topText"] else { return }
                guard let bottomText = object["bottomText"] else { return }
                guard let memeNumberPassed = object["memeNumber"] else { return }
                let memeNumber = Int(memeNumberPassed)!
                
                self.memes[memeNumber].name = memeName
                self.memes[memeNumber].textTop = topText
                self.memes[memeNumber].textBottom = bottomText
                
                self.save()
                self.collectionView.reloadData()
            })
        }
    }
    
//Setup Collection ViewController
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? Cell else { fatalError("Unable to dequeue cell") }
        
        let meme = memes[indexPath.item]
        
        let path = getDocumentsDirectory().appendingPathComponent(meme.editedImage)
        
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.cellName.text = meme.name
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.imageView.layer.cornerRadius = 10
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meme = memes[indexPath.item]
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.memeName = meme.name
            vc.originalImage = meme.originalImage
            vc.editedImage = meme.editedImage
            vc.topText = meme.textTop
            vc.bottomText = meme.textBottom
            vc.memeNumber = indexPath.item
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { [weak self] _ in
            
            let rename = UIAction(title: "Rename",
                                  image: UIImage(systemName: "square.and.pencil"),
                                  handler: { _ in
                
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
                
                let ac = UIAlertController(title: "Rename Your Meme", message: "", preferredStyle: .alert)
                ac.addTextField { (textField) in
                    var textToDisplay = self!.memes[indexPath.item].name
                    if textToDisplay == "New Meme" { textToDisplay = ""}
                    
                    textField.text = textToDisplay
                }
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak ac] _ in
                    guard let newText = ac?.textFields?[0].text else { return }
                    self!.memes[indexPath.item].name = newText
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    self!.save()
                    collectionView.reloadData()
                })
                self!.present(ac, animated: true)
                
            })
            
            let delete = UIAction(title: "Delete",
                                  image: UIImage(systemName: "trash"),
                                  attributes: .destructive,
                                  handler: { _ in
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
                self!.memes.remove(at: indexPath.item)
                self!.save()
                collectionView.reloadData()
            })
            
            return UIMenu(title: "",
                          image: nil,
                          identifier: nil,
                          options: UIMenu.Options.displayInline,
                          children: [rename, delete])
        })
        
        return config
    }
    
//App's logics
    @objc func createNewMeme() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let originalImageName = UUID().uuidString
        let originalImagePath = getDocumentsDirectory().appendingPathComponent(originalImageName)
        let editedImageName = UUID().uuidString
        let editedImagePath = getDocumentsDirectory().appendingPathComponent(editedImageName)
        
        if let jpegData = image.jpegData(compressionQuality: 1) {
            try? jpegData.write(to: originalImagePath)
            try? jpegData.write(to: editedImagePath)
        }
        
        let meme = Meme(name: "New Meme", originalImage: originalImageName, editedImage: (editedImageName), textTop: "", textBottom: "")
        memes.append(meme)
        
        save()
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.memeName = meme.name
            vc.originalImage = meme.originalImage
            vc.editedImage = meme.editedImage
            vc.topText = meme.textTop
            vc.bottomText = meme.textBottom
            vc.memeNumber = memes.count - 1
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        let defaults = UserDefaults.standard
        
        if VCLoaded {
            if let savedData = try? jsonEncoder.encode(memes) {
                defaults.set(savedData, forKey: "memes")
            } else { print("Failed to save Memes") }
        } else {
            if let savedMoments = defaults.object(forKey: "memes") as? Data {
                let jsonDecoder = JSONDecoder()

                do {
                    memes = try jsonDecoder.decode([Meme].self, from: savedMoments)
                } catch { print("Failed to load Memes") }
            }
        }
    }

}

