//
//  PostListViewModel.swift
//  iForageTest
//
//  Created by Connor A Lynch on 29/11/2021.
//

import Foundation

class PostListViewModel: ObservableObject {
    
    @Published var searchIsActive: Bool = false
    @Published var searchText: String = ""
    
    @Published var posts = [Post]()
    
    init(){
        fetchPosts()
    }
    
    var filteredPosts: [Post] {
        let query = searchText.lowercased()
        return searchText.isEmpty ? posts : posts.filter( { $0.title.lowercased().contains(query) })
    }
    
    func fetchPosts(){
        Task {
            self.posts = try await CloudKitManager.shared.fetchPosts()
        }
    }
}
