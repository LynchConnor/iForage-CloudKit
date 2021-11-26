//
//  ContentView.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//

import MapKit
import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var manager: CloudKitManager
    
    @State var isActive: Bool = false
    
    var body: some View {
        VStack {
            switch manager.state {
            case .signedIn:
                HomeView()
            case .loading:
                ProgressView()
            case .signedOut:
                OnboardingView()
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(CloudKitManager())
    }
}
