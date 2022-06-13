//
//  Meme.swift
//  Project8 - Meme Generator
//
//  Created by Vitali Vyucheiski on 5/27/22.
//

import UIKit

class Meme: NSObject, Codable {
    var name: String
    var originalImage: String
    var editedImage: String
    var textTop: String
    var textBottom: String
    
    init(name: String, originalImage: String, editedImage: String, textTop: String, textBottom: String) {
        self.name = name
        self.originalImage = originalImage
        self.editedImage = editedImage
        self.textTop = textTop
        self.textBottom = textBottom
    }
}
