//
//  PostDetailView.swift
//  iForageTest
//
//  Created by Connor A Lynch on 26/11/2021.
//

import CloudKit
import SwiftUI

extension PostDetailView {
    @MainActor class ViewModel: ObservableObject {
        @Published var post: Post
        @Published var isEditing: Bool = false
        @Binding var posts: [Post]
        
        @Published var postCoordinate: CLLocation?
        
        @Published var centerCoordinate = CLLocationCoordinate2D(latitude: LocationManager.shared.coordinate.latitude, longitude: LocationManager.shared.coordinate.longitude)
        
        @Published var confirmationShown: Bool = false
        
        init(post: Post, posts: Binding<[Post]>){
            _posts = posts
            self.postCoordinate = post.coordinate
            self.post = post
            self.centerCoordinate = CLLocationCoordinate2D(latitude: post.coordinate.coordinate.latitude, longitude: post.coordinate.coordinate.longitude)
            isFavourite()
        }
        
        func updatePost(){
            Task {
                
                let record = try await CloudKitUtility.fetchRecord(recordID: post.id)
                
                record[Post.kCaption] = post.caption
                
                let _ = try await CloudKitUtility.modifyRecords(records: [record])
            }
        }
        
        func isFavourite(){
            //Fetch record
            Task {
                let record = try await CloudKitUtility.fetchRecord(recordID: post.id)
                
                if let isLiked = record[Post.kIsLiked] as? Bool {
                    self.post.isLiked = isLiked
                }else{
                    self.post.isLiked = false
                }
                
            }
        }
        
        func deletePost(){
            Task {
                try await CloudKitUtility.deleteRecord(recordID: post.id)
                guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
                print("Index: \(index)")
                posts.remove(at: index)
            }
        }
        
        func unFavouritePost(){
            
            //Fetch record
            
            Task {
                
                //Fetch post record
                
                let record = try await CloudKitUtility.fetchRecord(recordID: post.id)
                
                //Update record
                
                record[Post.kIsLiked] = nil
                
                post.isLiked = nil
                
                //Update database
                
                try await CloudKitUtility.modifyRecords(records: [record])
            }
        }
        
        var isLiked: Bool {
            guard let isLiked = post.isLiked else { return false }
            return isLiked
        }
        
        func favouritePost(){
            
            //Fetch record
            
            Task {
                
                //Fetch post record
                
                let record = try await CloudKitUtility.fetchRecord(recordID: post.id)
                
                //Update record
                
                record[Post.kIsLiked] = true
                
                post.isLiked = true
                
                //Update database
                
                try await CloudKitUtility.modifyRecords(records: [record])
            }
        }
    }
}

struct PostDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
        
        UITextView.appearance().backgroundColor = .clear
        UITextView.appearance().textContainerInset =
        UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
    }
    
    var body: some View {
        VStack {
            
            if let post = viewModel.post {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottom) {
                            
                            StretchingHeader(height: 275) {
                                Image(uiImage: post.image.toUIImage())
                            }
                            .overlay(
                                
                                LinearGradient(colors: [.clear, .clear, .black.opacity(0.15), .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                    .clipped()
                                
                                ,alignment: .bottom
                                
                            )// - Overlay
                            
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    
                                    //MARK: Name
                                    Text(post.title)
                                        .kerning(1)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }// - HStack
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            
                        }// - ZStack
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(alignment: .center, spacing: 5) {
                                
                                Text("Notes")
                                    .kerning(2)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                HStack {
                                    
                                    if viewModel.isEditing {
                                        
                                        Spacer()
                                        
                                        //MARK: Save
                                        Button {
                                            //Update notes
                                            viewModel.updatePost()
                                            viewModel.isEditing = false
                                        } label: {
                                            Text("Save")
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        
                                    }
                                }
                                
                            }// - HStack
                            
                            //MARK: Notes
                            
                            if !viewModel.isEditing {
                                
                                Text(viewModel.post.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .font(.system(size: 17, weight: .light))
                                    .lineSpacing(8)
                                    .multilineTextAlignment(.leading)
                            }else{
                                ZStack {
                                    TextEditor(text: $viewModel.post.caption)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .font(.system(size: 17, weight: .light))
                                        .lineSpacing(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(3)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(viewModel.post.caption).opacity(0).padding(.all, 8)
                                }
                            }
                            
                            Rectangle()
                                .frame(height: 1)
                                .padding(.vertical, 5)
                            
                            VStack(alignment: .leading) {
                            
                                Text("Map")
                                    .kerning(2)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                
                                ZStack {
                                    
                                    MapView(centerCoordinate: $viewModel.centerCoordinate, isZoomEnabled: false, isRotateEnabled: false, isScrollEnabled: false)
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                    
                                    MapAnnotationCell(image: post.image.toUIImage())
                                    
                                }
                            }
                            
                            Spacer()
                            
                        }// - VStack
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    
                    // - VStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                // - ScrollView
                .overlay(
                    
                    HStack(alignment: .top) {
                        
                        ZStack {
                            
                            Circle()
                                .foregroundColor(Color.black.opacity(0.5))
                            
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "arrow.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17, height: 17)
                                    .font(.system(size: 1, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(13)
                            }// - Button
                            
                        }
                        // - ZStack
                        .frame(width: 45, height: 45)
                        
                        Spacer()
                        
                        Button {
                            viewModel.isLiked ? viewModel.unFavouritePost() : viewModel.favouritePost()
                        } label: {
                            ZStack {
                                
                                Circle()
                                    .foregroundColor(Color.black.opacity(0.5))
                                
                                Image(systemName: (viewModel.isLiked) ? "heart.fill" : "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(13)
                                    .foregroundColor(viewModel.isLiked ? .red : .white)
                                
                            }// - ZStack
                            .frame(width: 45, height: 45)
                            
                        }// - Button
                        
                        Menu {
                            
                            Button {
                                viewModel.isEditing.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                    Text("Edit Notes")
                                }
                            }
                            
                            Button(role: .destructive) {
                                
                                viewModel.confirmationShown = true
                                
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.bin")
                                    Text("Delete")
                                }
                            }

                            
                        } label: {
                            
                                ZStack {
                                    
                                    Circle()
                                        .foregroundColor(Color.black.opacity(0.5))
                                    
                                    Image(systemName: "ellipsis")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(13)
                                        .foregroundColor(.white)
                                    
                                }// - ZStack
                                .frame(width: 45, height: 45)
                        }
                        .frame(width: 45, height: 45)

                        
                    }
                    // - HStack
                        .padding(.top, 40)
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ,alignment: .top
                )// - Overlay
                
                .confirmationDialog("Are you sure?", isPresented: $viewModel.confirmationShown, titleVisibility: .visible) {
                    Button("Yes") {
                        viewModel.deletePost()
                        dismiss()
                    }
                }
                
            }//IF LET POST
            else{
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea(.all, edges: .top)
        .navigationTitle("")
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(viewModel: PostDetailView.ViewModel(post: Post(record: CKRecord(recordType: RecordType.post)), posts: .constant([])))
    }
}
