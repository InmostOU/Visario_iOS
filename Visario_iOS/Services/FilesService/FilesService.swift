//
//  FilesService.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 29.09.2021.
//

import UIKit

final class FilesService: NSObject {
    
    var savingCompletion: () -> Void = { }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
        savingCompletion()
    }
}
