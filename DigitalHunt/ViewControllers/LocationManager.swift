//
//  LocationManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 20/10/23.
//


import UIKit
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    var locationManager: CLLocationManager

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func calculateDistance(from sourceLocation: CLLocation?, to destinationLocation: CLLocation) -> CLLocationDistance? {
        if let source = sourceLocation {
            return source.distance(from: destinationLocation)
        }
        return nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let location = locationManager.location else {return}
  
  switch locationManager.authorizationStatus {
  case .authorizedWhenInUse, .authorizedAlways:
      //let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
      //mapView.setRegion(region, animated: true)
      print("current GPS: \(location.coordinate.latitude) \(location.coordinate.latitude)")
  case .denied:
      print("Location services has been denied.")
  case .notDetermined, .restricted:
      print("Location cannot be determined or restricted.")
  @unknown default:
      print("Unknow error. Unable to get current location.")
  }    }

    // Altri metodi relativi alla gestione della posizione

    // CLLocationManagerDelegate methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Gestisci gli aggiornamenti sulla posizione qui
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

