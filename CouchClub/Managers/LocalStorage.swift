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
    
    private init() {}
    
    private var fileManager: FileManager {
        return FileManager.default
    }
    
    private var documentsDirectory: URL {
        self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent("images")
    }
    
    func cleanupAfterLogout() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            do {
                let imageNames = try fileManager.contentsOfDirectory(atPath: imagesDirectory.path)
                
                for imageName in imageNames {
                    try self.fileManager.removeItem(atPath: "\(self.imagesDirectory.path)/\(imageName)")
                }
            } catch {
                print("Local Storage | Error when clearing the images folder: ", error.localizedDescription)
            }
        }
    }
    
    func saveImage(_ image: UIImage, named imageName: String) {
        DispatchQueue.global(qos: .utility).async { [unowned self, weak image] in
            guard let image = image else { return }
            let path = self.imagesDirectory.appendingPathComponent(imageName)
            var directoryExists = true
            
            if !self.fileManager.fileExists(atPath: self.imagesDirectory.path) {
                do {
                    try FileManager.default.createDirectory(at: self.imagesDirectory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Local Storage | Error when creating the images directory: ", error.localizedDescription);
                    directoryExists = false
                }
            }

            if directoryExists, let jpegData = image.jpegData(compressionQuality: 0.8) {
                do {
                    try jpegData.write(to: path)
                } catch let error as NSError {
                    print("Local Storage | Error when storing image: ", error.localizedDescription)
                }
            }
        }
    }
    
    func getImage(_ imageName: String) -> UIImage? {
        let imagePath = imagesDirectory.appendingPathComponent(imageName)
        
        return UIImage(contentsOfFile: imagePath.path)
    }
    
}
