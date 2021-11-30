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
        
        @Published var centerCoordinate = CLLocationCoordinate2D(latitude: LocationManager.shared.coordinate.latitude, longitude: LocationManager.shared.coordinate.longitude)
        
        @Published var containerHeight: CGFloat = 200
        
        @Published var showImagePicker: Bool = false
        @Published var showCamera: Bool = false
        
        @Published var showMap: Bool = false
        
        @ObservedObject var postListVM: PostListViewModel
        
        @Published var showConfirmationSheet: Bool = false
        
        @Published var title: String = ""
        @Published var caption: String = "Write what you want here..."
        @Published var selectedImage: UIImage?
        @Published var location: CLLocation?
        
        init(postListVM: PostListViewModel){
            _postListVM = ObservedObject(wrappedValue: postListVM)
        }
        
        func uploadPost() async {
            if validatePost(){
                
                Task {
                    
                    let record = CKRecord(recordType: RecordType.post)
                    record[Post.kTitle] = title
                    record[Post.kCaption] = caption
                    record[Post.kImage] = selectedImage?.convertToCKAsset()
                    guard let location = await LocationManager.shared.fetchLocation() else { return }
                    record[Post.kCoordinate] = location
                    
                    do {
                        try await CloudKitManager.shared.saveRecord(record: record)
                        
                        postListVM.posts.append(Post(record: record))
                        
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
    
    @FocusState private var focusField: Field?
    
    enum Field {
        case title
        case notes
    }
    
    init(viewModel: ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            ZStack {
                
                VStack(spacing: 5) {
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .padding(.vertical, 15)
                        Spacer()
                        
                        Button {
                            Task {
                                await viewModel.uploadPost()
                                dismiss()
                            }
                        } label: {
                            Text("Create Post")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 18)
                                .background(Color.blue)
                        }
                        .cornerRadius(5)
                        .disabled(viewModel.selectedImage == nil || viewModel.title == "" || viewModel.caption == "")
                        .opacity(viewModel.selectedImage == nil || viewModel.title == "" || viewModel.caption == "" ? 0.6 : 1)
                    }
                    .padding(.vertical, 10)
                    
                    Button {
                        viewModel.showConfirmationSheet = true
                    } label: {
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(0)
                        }else{
                            
                            ZStack {
                                Rectangle()
                                
                                ZStack {
                                    Circle()
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(Color.init(red: 44/255, green: 108/255, blue: 100/255))
                                    Image(systemName: "photo")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipped()
                                }// - ZStack
                                .frame(height: 200)
                                .clipShape(Circle())
                                
                            }// - ZStack
                        }
                        
                    }// - Button
                    .confirmationDialog("Choose your preferred media", isPresented: $viewModel.showConfirmationSheet, titleVisibility: .visible) {
                        Button {
                            viewModel.showCamera = true
                            viewModel.showImagePicker = true
                        } label: {
                            Text("Camera")
                        }
                        
                        Button {
                            viewModel.showCamera = false
                            viewModel.showImagePicker = true
                        } label: {
                            Text("Photo Library")
                        }

                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(5)
                    .clipped()
                    
                    VStack(spacing: 5) {
                        
                        TextField("Name your plant here...", text: $viewModel.title)
                            .focused($focusField, equals: .title)
                            .submitLabel(.continue)
                            .font(.system(size: 22, weight: .semibold))
                            .padding(.vertical, 15)
                        
                        AutoSizeTextField(text: $viewModel.caption, hint: "What do you want to say about your find? Tap to write...", containerHeight: $viewModel.containerHeight){
                            
                        }
                        .frame(height: viewModel.containerHeight <= 200 ? viewModel.containerHeight : 200)
                            .focused($focusField, equals: .notes)
                            .submitLabel(.continue)
                            .lineSpacing(8)
                            .cornerRadius(5)
                            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 20)
                        
                    }// - VStack
                    .onSubmit {
                        switch focusField {
                            case .title:
                                focusField = .notes
                            default:
                                return
                        }
                    }
                    
                    VStack(spacing: 15) {
                        
                        HStack(spacing: 0) {
                            Text("Use current location?")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(viewModel.showMap ? "No" : "Yes")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.gray)
                                
                            Toggle(isOn: $viewModel.showMap) {
                                    Text("")
                                }
                                .frame(width: 60)
                        }
                        .padding(.trailing, 10)
                        
                            
                        if viewModel.showMap {
                            
                            ZStack {
                                
                                MapView(centerCoordinate: $viewModel.centerCoordinate)
                                    .frame(height: 250)
                                    .cornerRadius(10)
                                
                                
                                Circle()
                                    .foregroundColor(.blue)
                                    .frame(width: 35, height: 35, alignment: .center)
                                    .opacity(0.5)
                                
                            }
                        }
                        
                    }

                    
                }// - VStack
                
            }// - VStack
            
            
        }// - ScrollView
        .sheet(isPresented: $viewModel.showImagePicker, content: {
            ImagePicker(sourceType: viewModel.showCamera ? .camera : .photoLibrary, selectedImage: $viewModel.selectedImage)
                .edgesIgnoringSafeArea(.all)
        })
        // - VStack
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView(viewModel: CreatePostView.ViewModel(postListVM: PostListViewModel()))
    }
}
