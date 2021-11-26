//
//  LocationManager.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//

import CoreLocation
import Foundation
import SwiftUI
import MapKit

let defaultRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 200, longitudinalMeters: 200)

class LocationManager: NSObject, ObservableObject {
    
    private var manager: CLLocationManager
    
    @Published var location: CLLocation?
    @Published var region: MKCoordinateRegion = defaultRegion
    
    static let shared = LocationManager()
    
    override init(){
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        Task {
            await requestAuthorization()
            await requestLocation()
        }
    }
    
    func requestAuthorization() async { manager.requestAlwaysAuthorization() }
    
    func requestLocation() async { manager.requestLocation() }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.location = location
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 200, longitudinalMeters: 200)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: \(error.localizedDescription)")
    }
    
}
