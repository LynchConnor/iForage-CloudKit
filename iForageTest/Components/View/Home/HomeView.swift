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
    }
}

struct HomeView: View {
    
    @StateObject var postListVM = PostListViewModel()
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: postListVM.posts) { post in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: post.coordinate.coordinate.latitude, longitude: post.coordinate.coordinate.longitude)) {
                        
                        NavigationLink {
                            LazyView(PostDetailView(viewModel: PostDetailView.ViewModel(post: post, viewModel: postListVM)))
                        } label: {
                            MapAnnotationCell(image: post.image.toUIImage())
                        }
                        .isDetailLink(false)
                    }
                }.edgesIgnoringSafeArea(.all)
                
                
                HStack(spacing: 25) {
                    
                    NavigationLink {
                        ExploreView()
                            .environmentObject(postListVM)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .isDetailLink(false)
                    
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background(Color.white)
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
            CreatePostView(viewModel: CreatePostView.ViewModel(postListVM: postListVM))
        })
        .task {
            await LocationManager.shared.requestLocation()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct MapAnnotationCell: View {
    
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50, alignment: .center)
            .clipShape(Circle())
            .padding(3)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
    }
}
