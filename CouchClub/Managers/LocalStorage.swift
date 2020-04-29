//
//  LocalStorage.swift
//  CouchClub
//
//  Created by Ruben Dias on 29/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

final class LocalStorage {
    
    static let shared = LocalStorage()
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent("images")
    }
    
    func store(_ image: UIImage, named imageName: String) {
        DispatchQueue.global(qos: .utility).async { [unowned self, weak image] in
            guard let image = image else { return }
            let path = self.imagesDirectory.appendingPathComponent(imageName)
            var directoryExists = true
            
            if !FileManager.default.fileExists(atPath: self.imagesDirectory.path) {
                do {
                    try FileManager.default.createDirectory(at: self.imagesDirectory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error when creating the images directory: ", error.localizedDescription);
                    directoryExists = false
                }
            }

            if directoryExists, let jpegData = image.jpegData(compressionQuality: 0.8) {
                do {
                    try jpegData.write(to: path)
                } catch let error as NSError {
                    print("Error when storing image: ", error.code)
                }
            }
        }
    }
    
    func retrieve(_ imageName: String) -> UIImage? {
        let imagePath = imagesDirectory.appendingPathComponent(imageName)
        let imageExists = FileManager.default.fileExists(atPath: imagePath.path)
        
        if imageExists {
            return UIImage(contentsOfFile: imagePath.path)
        } else {
            return nil
        }
    }
    
}
