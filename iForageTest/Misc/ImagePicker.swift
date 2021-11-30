//
//  ImagePicker.swift
//  iForageTest
//
//  Created by Connor A Lynch on 26/11/2021.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
}

extension ImagePicker {
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(parent: ImagePicker){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.editedImage] as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.parent.selectedImage = image
                picker.dismiss(animated: true)
            }
        }
    }
}
