//
//  LocationManager.swift
//  VirtusaTest
//
//  Created by Shailesh Gole on 05/05/23.
//

import Foundation
import CoreLocation


protocol CurrentLocationProtocol {
  func didReceivedCurrentLocation(currentLocation: (Double, Double))
}

class LocationManager: NSObject {
  let clLocationManager = CLLocationManager()
  var currentLocationDelegate: CurrentLocationProtocol?
  
  func askForPermission() {
    clLocationManager.delegate = self
    clLocationManager.requestWhenInUseAuthorization()
    clLocationManager.requestLocation()
  }
}

extension LocationManager: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    currentLocationDelegate?.didReceivedCurrentLocation(currentLocation: (location.coordinate.latitude, location.coordinate.longitude))
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error \(error)")
  }
}

