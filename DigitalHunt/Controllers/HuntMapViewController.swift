//
//  HuntMapViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//

import UIKit
import CoreLocation
import MapKit

class HuntMapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!


    var track = Track()
    let locationManager = DHLocationManager.shared
    //let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = track.name
        setupBackButton()
        locationManager.locationManager.delegate = self
        locationManager.locationManager.startUpdatingLocation()
        updateLocationOnMap()
    }
    
    private func updateLocationOnMap() {
        let region = locationManager.calculateRegion()
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocationOnMap()
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errore nell'aggiornamento della posizione: \(error.localizedDescription)")
    }
    
    func setupBackButton(){
        let newBackButton = UIBarButtonItem(title: "Annulla", style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = newBackButton

    }

    @objc func back(_ sender: UIBarButtonItem?) {
        navigationItem.hidesBackButton = true
        let ac = UIAlertController(title: "Annullare la gara in corso?", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Si", style: .destructive, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        ac.addAction(yes)
        ac.addAction(no)
        self.present(ac, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
