//
//  LocationManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 20/10/23.
//

import UIKit
import MapKit


class DHLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = DHLocationManager()  
    var locationManager: CLLocationManager
    
    private let showLog: Bool = false

    
    override init() {
        locationManager = CLLocationManager()
        super.init()  //override dell'init del padre
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {  // lo lascio qua per eventuale riuso o aggiunta operazioni in questa fase
        if showLog { print("LocMan - sono in 'requestAuthorization()'")}
        locationManager.requestWhenInUseAuthorization()
    }

    func checkLocationAuthorization() {
    if showLog { print("LocMan - sono in 'checkLocationAuthorization()'")}
      switch locationManager.authorizationStatus {
      case .authorizedWhenInUse, .authorizedAlways:
          if (locationManager.location != nil)  {
              if showLog { print("LocMan - location non NIL")}
          } else {
              if showLog { print("LocMan - location NIL")}
              return
          }
          if showLog { print("LocMan - trovata posizione:")}
          if showLog { print("       -> trovata posizione: \(String(describing: locationManager.location?.coordinate.latitude))")}
          if showLog { print("       -> trovata posizione: \(String(describing: locationManager.location?.coordinate.longitude))")}
      case .denied:
          print("Location services has been denied.")
      case .notDetermined, .restricted:
          print("Location cannot be determined or restricted.")
      @unknown default:
          print("Unknow error. Unable to get current location.")
      }
    }
    
    func calculateRegion() -> MKCoordinateRegion {
        if showLog { print("LocMan - sono in 'calculateRegion()'")}
        let coordinates : CLLocationCoordinate2D = locationManager.location!.coordinate
        let spanDegree = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        return MKCoordinateRegion(center: coordinates, span: spanDegree)
    }
    
    func calculateDistanceFromHere(lat: Double, long: Double) -> Int {
        let destinationLocation = CLLocation(latitude: lat, longitude: long)
        let distance = locationManager.location?.distance(from: destinationLocation)
        if showLog { print("LocMan - sono in 'calculateDistanceFromHere'")}
        return Int(distance ?? -1)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if showLog { print("LocMan - sono in 'locationManagerDidChangeAuthorization' in classe primaria")}
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}

