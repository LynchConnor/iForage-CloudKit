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
    
    @Published var currentLocation: CLLocation?
    @Published var region: MKCoordinateRegion = defaultRegion
    
    static let shared = LocationManager()
    
    var coordinate: CLLocationCoordinate2D {
        guard let location = currentLocation else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

    }
    
    override init(){
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        Task {
            await requestAuthorization()
            await requestLocation()
        }
    }
    
    func fetchLocation() async -> CLLocation? {
        await requestLocation()
        guard let location = currentLocation else { return nil }
        return location
    }
    
    func requestAuthorization() async { manager.requestAlwaysAuthorization() }
    
    func requestLocation() async { manager.requestLocation() }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
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
