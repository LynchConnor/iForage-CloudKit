//
//  CreatePostView.swift
//  iForageTest
//
//  Created by Connor A Lynch on 26/11/2021.
//
import CloudKit
import CoreLocation
import SwiftUI

extension CKAsset {
    func toUIImage() -> UIImage {
        guard let url = self.fileURL,
              let data = NSData(contentsOf: url),
              let image = UIImage(data: data as Data)
        else { return UIImage(systemName: "photo")! }
        return image
    }
}

extension UIImage {
    func convertToCKAsset() -> CKAsset? {
        guard
            let urlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = urlPath.appendingPathComponent("selectedPostImage")
        guard let imageData = self.jpegData(compressionQuality: 0.5) else { return nil }
        
        do {
            try imageData.write(to: fileURL)
            return CKAsset(fileURL: fileURL)
        }catch {
            return nil
        }
    }
}

extension CreatePostView {
    class ViewModel: ObservableObject {
        
        @ObservedObject var homeViewModel: HomeView.ViewModel
        
        @Published var isActive: Bool = false
        
        @Published var title: String = ""
        @Published var caption: String = ""
        @Published var selectedImage: UIImage?
        @Published var location: CLLocation?
        
        init(homeViewModel: HomeView.ViewModel){
            _homeViewModel = ObservedObject(wrappedValue: homeViewModel)
        }
        
        func createPost() async {
            if validatePost(){
                
                Task {
                    await LocationManager.shared.requestLocation()
                    
                    let record = CKRecord(recordType: RecordType.post)
                    record[Post.kTitle] = title
                    record[Post.kCaption] = caption
                    record[Post.kImage] = selectedImage?.convertToCKAsset()
                    record[Post.kCoordinate] = LocationManager.shared.location
                    
                    do {
                        try await CloudKitManager.shared.saveRecord(record: record)
                        
                        homeViewModel.posts.append(Post(record: record))
                        
                    }catch {
                        print("DEBUG: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        private func validatePost() -> Bool {
            return !(title.isEmpty) || !(caption.isEmpty) || selectedImage != nil || location != CLLocation(latitude: 0, longitude: 0)
        }
    }
}

struct CreatePostView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Button {
                viewModel.isActive = true
            } label: {
                Text("Select image")
            }
            
            TextField("Title", text: $viewModel.title)
            TextField("Caption", text: $viewModel.caption)
            
            Button {
                Task {
                    await viewModel.createPost()
                    
                    dismiss()
                }
            } label: {
                Text("Save")
            }


        }
        .sheet(isPresented: $viewModel.isActive) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.selectedImage)
        }
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView(viewModel: CreatePostView.ViewModel(homeViewModel: HomeView.ViewModel()))
    }
}
