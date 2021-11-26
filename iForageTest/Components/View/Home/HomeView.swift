//
//  HomeView.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//

import MapKit
import SwiftUI

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var region = LocationManager.shared.region
        @Published var isActive: Bool = false
        
        @Published var posts = [Post]()
        
        init(){
            Task {
                self.posts = await fetchPosts()
            }
        }
        
        func fetchPosts() async -> [Post] {
            do {
                return try await CloudKitManager.shared.fetchPosts()
            }catch{
                print("DEBUG: \(error.localizedDescription)")
                return []
            }
        }
    }
}

struct HomeView: View {
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.posts) { post in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: post.coordinate.coordinate.latitude, longitude: post.coordinate.coordinate.longitude)) {
                    
                    NavigationLink {
                        PostDetailView(viewModel: PostDetailView.ViewModel(post: post))
                    } label: {
                        Image(uiImage: post.image.toUIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50, alignment: .center)
                            .clipShape(Circle())
                            .padding(3)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
                    }
                    .isDetailLink(false)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .overlay(
            Button(action: {
                viewModel.isActive = true
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60, alignment: .center)
                    .padding(5)
                    .background(Color.white)
                    .clipShape(Circle())
            })
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
                .padding(.bottom, 20)
                .padding()
            ,alignment: .bottomTrailing
        )
        .sheet(isPresented: $viewModel.isActive, content: {
            CreatePostView(viewModel: CreatePostView.ViewModel(homeViewModel: viewModel))
        })
        .edgesIgnoringSafeArea(.all)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
