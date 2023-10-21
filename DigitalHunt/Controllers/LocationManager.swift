//
//  LocationManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 20/10/23.
//


import UIKit
import MapKit


class DHLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = DHLocationManager()  //per singleton
    var locationManager: CLLocationManager
    //var location: CLLocation?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()  //perchè devo fare override dell'init del padre
        //locationManager.delegate = self   //appoggiati come delegate su questa stessa classe
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.startUpdatingLocation()
    }

    func requestAuthorization() {  // lo lascio qua per eventuale riuso o aggiunta operazioni in questa fase
        locationManager.requestWhenInUseAuthorization()
    }

    func calculateDistance(to destinationLocation: CLLocation) -> CLLocationDistance? {
        if locationManager.location != nil {
            return locationManager.location!.distance(from: destinationLocation)
        }
        return nil
    }

    func checkLocationAuthorization() {
     
      switch locationManager.authorizationStatus {
      case .authorizedWhenInUse, .authorizedAlways:
          if (locationManager.location != nil)  {
              print("Location non nil")
          } else {
              print("Non c'è una location")
              return
          }
          print("current GPS in change aut: \(locationManager.location?.coordinate.latitude) \(locationManager.location?.coordinate.latitude)")
      case .denied:
          print("Location services has been denied.")
      case .notDetermined, .restricted:
          print("Location cannot be determined or restricted.")
      @unknown default:
          print("Unknow error. Unable to get current location.")
      }
                
    }
    
    func calculateRegion() -> MKCoordinateRegion {
        let coordinates : CLLocationCoordinate2D = locationManager.location!.coordinate
        let spanDegree = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        return MKCoordinateRegion(center: coordinates, span: spanDegree)
    }
    
    // CLLocationManagerDelegate methods
/*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("sono in didUpdateLcoation è la posizione è  \(locationManager.location)")
    }
  */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("ChecckodaClassePrimaria")
        checkLocationAuthorization()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

