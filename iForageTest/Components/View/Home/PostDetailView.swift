//
//  PostDetailView.swift
//  iForageTest
//
//  Created by Connor A Lynch on 26/11/2021.
//

import CloudKit
import SwiftUI

extension PostDetailView {
    class ViewModel: ObservableObject {
        @Published var post: Post
        
        init(post: Post){
            self.post = post
        }
    }
}

struct PostDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = ViewModel(post: Post(record: CKRecord(recordType: RecordType.post) ))
    
    var body: some View {
        ScrollView {
            VStack {
                
                if let image = viewModel.post.image.toUIImage() {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
                
                Text("\(viewModel.post.title)")
                
                Text("\(viewModel.post.caption)")
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView()
    }
}
