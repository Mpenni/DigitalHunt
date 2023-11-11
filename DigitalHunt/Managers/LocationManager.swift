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
        super.init()  //perchè devo fare override dell'init del padre
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
    
    func calculateRegion() -> MKCoordinateRegion {   //TODO: credo non venga mai usata!
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
    
    func setupUserTrackingButtonAndScaleView(mapView: MKMapView, view: UIView) {
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(scale)
        
        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -10),
                                     button.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)])
    }
}

