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


    var track = Track() //??
    let locationManager = DHLocationManager.shared
    let statusManager = StatusManager.shared
    var currentNode :Node?
    var isStart :Bool = false
    var isEnd :Bool = false


    //let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = track.name
        statusManager.setStatusProp(key: "currentTrackId", value: track.id)
        setupBackButton()
        locationManager.locationManager.delegate = self
        locationManager.locationManager.startUpdatingLocation()
        updateLocationOnMap()
        defineTargetNode()
        checkIsSpecialNode()
    }
    
    private func defineTargetNode() {
        if statusManager.getStatusProp(key: "currentTrackId") != track.id {//some error go to main
            }
        if statusManager.getStatusProp(key: "nextNodeId") == nil {
            currentNode = track.Nodes.first!
            statusManager.setStatusProp(key: "nextNodeId", value: currentNode!.id)
            } else if statusManager.getStatusProp(key: "nextNodeId") != nil {
            currentNode = track.Nodes.first(where: { $0.id == statusManager.getStatusProp(key: "nextNodeId")})!
            } else {
            //some error go to main
            }
        if currentNode == nil {
            //some error go to main
        }
    }
    
    func checkIsSpecialNode() {
        if let firstNode = track.Nodes.first, let lastNode = track.Nodes.last {
            if currentNode!.id == firstNode.id {
                isStart = true
                isEnd = false
                print("Il nodo corrente è la partenza!")
            } else if currentNode!.id == lastNode.id {
                isStart = false
                isEnd = true
                print("Il nodo corrente è l'arrivo!")
            } else {
                isStart = false
                isEnd = false
                print("Il nodo corrente non è importante!")
            }
        } else {
            // Nessun nodo disponibile in Nodes
            isStart = false
            isEnd = false
            // error go to main
        }
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
