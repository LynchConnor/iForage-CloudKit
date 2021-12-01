//
//  ContentView.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//

import MapKit
import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var LManager: LocationManager
    @EnvironmentObject var CKManager: CloudKitManager
    
    @State var isActive: Bool = false
    
    var body: some View {
        VStack {
            switch CKManager.state {
            case .signedIn:
                HomeView()
                    .task {
                        await LManager.requestAuthorization()
                        await LManager.requestLocation()
                    }
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
