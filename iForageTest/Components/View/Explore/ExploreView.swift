//
//  ExploreView.swift
//  iForageTest
//
//  Created by Connor A Lynch on 29/11/2021.
//

import CoreLocation
import SwiftUI

struct ExploreView: View {
    
    @EnvironmentObject var postListVM: PostListViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var searchIsTapped: Bool = false
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10, alignment: .center)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 20) {
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .font(.system(size: 18, weight: .semibold))
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                }
                
                
                HStack(spacing: 8) {
                    
                    TextField("Search", text: $postListVM.searchText)
                        .submitLabel(.search)
                        .tint(.white)
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                        .overlay(
                            VStack {
                                if postListVM.searchText.count > 1 {
                                    Button(action: {
                                        postListVM.searchText = ""
                                    }, label: {
                                        Image(systemName: "xmark.circle.fill")
                                    })
                                }
                            }
                            ,alignment: .trailing
                        )
                    VStack {
                        if searchIsTapped {
                            
                            Button {
                                searchIsTapped = false
                                postListVM.searchText = ""
                            } label: {
                                Text("Cancel")
                            }
                            .animation(.easeInOut, value: searchIsTapped)
                        }
                    }
                    .animation(.easeInOut, value: searchIsTapped)
                    
                }// - HStack
                
                .onTapGesture {
                    searchIsTapped = true
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.gray.opacity(0.25))
            
            ScrollView(.vertical) {
                
                if postListVM.filteredPosts.isEmpty {
                    VStack(spacing: 10) {
                        
                        if postListVM.searchText != "" {
                            
                            Text("'\(Text(postListVM.searchText).bold())' can't be found")
                                .font(.system(size: 18))
                            Text("┐(‘～`；)┌")
                                .font(.system(size: 28, weight: .heavy))
                        }else{
                            Text("It doesn't look like you have any posts yet.")
                                .font(.system(size: 18))
                            Text("┐(‘～`；)┌")
                                .font(.system(size: 28, weight: .heavy))
                        }
                    }
                    .padding(.top, 25)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    VStack(alignment: .leading) {
                        ForEach(postListVM.filteredPosts){ post in
                            
                            NavigationLink {
                                LazyView(PostDetailView(viewModel: PostDetailView.ViewModel(post: post, viewModel: postListVM)))
                            } label: {
                                HStack {
                                    Image(uiImage: post.image.toUIImage())
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100, alignment: .center)
                                        .clipped()
                                        .cornerRadius(10)
                                    Text(post.title)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
                                    .padding(.horizontal, 15)
                            }
                        }
                    }
                    .padding(.top, 15)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onDisappear(perform: {
            postListVM.searchText = ""
        })
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
