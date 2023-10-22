//
//  HuntMapViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//  45.5 9.08

import UIKit
import CoreLocation
import MapKit

class HuntMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var track = Track() //??
    let locationManager = DHLocationManager.shared
    let statusManager = StatusManager.shared
    var currentNode :Node?
    var isStart :Bool = false
    var isEnd :Bool = false
    
    var timer:Timer = Timer()
    var count:Int = 0
    var timerCounting = false
   
    //let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.title = track.name
        statusManager.setStatusProp(key: "currentTrackId", value: track.id)
        statusManager.printAll()
        setupBackButton()
        locationManager.locationManager.delegate = self
        locationManager.locationManager.startUpdatingLocation()
        updateLocationOnMap()
        defineTargetNode()
        checkIsSpecialNode()
        drawMarker()
        checkIsInsideNode()
        
        //#TODO: Gestire Time fuori da qua
        timerCounting = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
    }
    
    @objc func timerCounter() -> Void
    {
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timeLabel.text = timeString
    
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    
    
    private func defineTargetNode() {
        if statusManager.getStatusProp(key: "currentTrackId") != track.id {//some error go to main
            // TODO: manage error and exit
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
    
    private func drawMarker() {
        let nodePin = MKPointAnnotation()
        nodePin.coordinate.latitude = currentNode!.lat
        nodePin.coordinate.longitude = currentNode!.long
        if isStart {
            nodePin.title = "INIZIO"
        } else if isEnd {
            nodePin.title = "FINE"
        } else {
            nodePin.title = "TAPPA"
        }
        //nodePin.subtitle = "Subtitle"
        mapView.addAnnotation(nodePin)
        let circle = MKCircle(center: nodePin.coordinate, radius: 10)
            mapView.addOverlay(circle)
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocationOnMap()
        checkIsInsideNode()
    }
    
    private func updateLocationOnMap() {
        let region = locationManager.calculateRegion()
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    private func checkIsInsideNode() {
        let currentLocation = locationManager.locationManager.location
        let center = CLLocation(latitude: currentNode!.lat, longitude: currentNode!.long)
        let distance = Int(round(currentLocation!.distance(from: center)))
        print("distanza: \(distance)")
        distanceLabel.text = "\(distance)m"
        //let radius: CLLocationDistance = 10.0
        let radius = 10
        if distance <= radius {
            distanceLabel.text = "0m"
            insideNode()
        } else {
            distanceLabel.text = "\(distance-10)m"
        }
    }

    private func insideNode(){
        print("INSIDE NODE!")
        if isStart {
            startGame()
        }
    }
    
    private func startGame(){
        statusManager.printAll()
        print("StartGame!")
        statusManager.setStartTimeNow()
        statusManager.printAll()
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errore nell'aggiornamento della posizione: \(error.localizedDescription)")
    }
    
    // Funzione per disegnare l'overlay del cerchio
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         if let circleOverlay = overlay as? MKCircle {
             let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
             circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
             circleRenderer.strokeColor = UIColor.blue
             circleRenderer.lineWidth = 1
             return circleRenderer
         }
         return MKOverlayRenderer(overlay: overlay)
     }
    
    func setupBackButton(){
        let newBackButton = UIBarButtonItem(title: "Annulla", style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = newBackButton

    }

    @objc func back(_ sender: UIBarButtonItem?) {
        navigationItem.hidesBackButton = true
        let ac = UIAlertController(title: "Annullare la gara in corso? Questa azione cancellerà tutti i tuoi progressi", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Si", style: .destructive, handler: { action in
            self.statusManager.resetStatus()
            self.statusManager.printAll()
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
