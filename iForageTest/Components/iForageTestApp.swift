//
//  iForageTestApp.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//

import SwiftUI

@main
struct iForageTestApp: App {
    
    let CKManager = CloudKitManager.shared
    let LManager = LocationManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainTabView()
                    .environmentObject(CKManager)
                    .environmentObject(LManager)
                    .task {
                        await CKManager.fetchCurrentUser()
                        await LManager.requestAuthorization()
                        await LManager.requestLocation()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}
