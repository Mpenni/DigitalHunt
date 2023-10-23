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
    
    @IBOutlet weak var legLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var track = Track() //??
    let locationManager = DHLocationManager.shared
    let statusManager = StatusManager.shared
    let timeManager = TimeManager.shared
    var currentNode :Node?  //#TODO non è meglio usare solo track.nodes[currentNodeIndex]?
    var isStart :Bool = false
    var isEnd :Bool = false
    var coordinates : CLLocationCoordinate2D?
    var distance: Int = -1
       
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.title = track.name
        statusManager.setStatusPropString(key: "currentTrackId", value: track.id)
        statusManager.printAll()
        setupBackButton()
        locationManager.locationManager.delegate = self
        locationManager.locationManager.startUpdatingLocation()
        
        //updateLocationOnMap()
        loadMap()
        
        drawAreaInMap()

        
        timeManager.updateHandler = { [weak self] timeString in self!.timeLabel.text = timeString}
    }
    
    private func loadMap() {
        guard let userLocation = locationManager.locationManager.location else {
                print("Posizione non disponibile.")
                return
        }
        coordinates = locationManager.locationManager.location!.coordinate
        let spanDegree = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinates!, span: spanDegree)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    private func drawAreaInMap() {
        defineTargetNode()
        checkIsSpecialNode()
        updateLabels()
        drawMarker()
        checkIsInsideNode()
    }
    
    
    
    private func defineTargetNode() {
        if statusManager.getStatusPropString(key: "currentTrackId") != track.id {//some error go to main
            // TODO: manage error and exit
            }
        if statusManager.getStatusPropInt(key: "currentNodeIndex") == nil {
            // non c'è in status currentNode
            currentNode = track.getCurrentNode()
            //currentNode = track.Nodes.first!
            statusManager.setStatusPropInt(key: "currentNodeIndex", value: track.currentNodeIndex)
        } else if statusManager.getStatusPropInt(key: "currentNodeIndex") != nil {
            // c'è in status currentNode
            currentNode = track.Nodes[statusManager.getStatusPropInt(key: "currentNodeIndex")!]
        } else {
            //some error go to main
            }
        if currentNode == nil {
            //some error go to main
        }
    }
    
    private func checkIsSpecialNode() {
        isStart = track.checkIsStartNode()
        isEnd = track.checkIsEndNode()
        print("isStart \(isStart)")
        print("isEnd \(isEnd)")        
    }
    
    /*
    func checkIsSpecialNode2() {
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
    } */
    
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
    
    private func updateLabels() {
        legLabel.text = "\(track.currentNodeIndex) di \(track.Nodes.count)"
        if track.currentNodeIndex == 0 {
            infoLabel.text = "Procedi verso l'area 'INIZIO'"
        } else {
            infoLabel.text = "Procedi verso la prossima area'"
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocationOnMap()
        checkIsInsideNode()
    }
    
    private func updateLocationOnMap() {
        guard let userLocation = locationManager.locationManager.location else {
                print("Posizione non disponibile.")
                return
        }
        coordinates = locationManager.locationManager.location!.coordinate
        mapView.setCenter(coordinates!, animated: true)
    }
    
    private func checkIsInsideNode() {
        let radius = 10
        distance = locationManager.calculateDistanceFromHere(lat: currentNode!.lat, long: currentNode!.long)
        if distance < 0 {
            distanceLabel.text = "-nd-"
        } else if distance <= radius {
            distanceLabel.text = "0m"
            insideNode()
        } else {
            distanceLabel.text = "\(distance-10)m"
        }
    }
    /*
    
    private func checkIsInsideNode2() {
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
*/
    private func insideNode(){
        print("INSIDE NODE!")
        infoLabel.text = "Hai raggiunto la destinazione"  //x debug
        if isEnd {
            endGame()
            return
        } else
        if isStart {
            startGame()
        }
        //per scopi di debug:
        self.performSegue(withIdentifier: "toQuizView", sender: track)

        
        
        //currentNode = track.changeNode()
        //print("Curren Node inddex: \(track.currentNodeIndex)")
        //drawAreaInMap()
        // l'incremento dell'index node lo faccio al termine del quiz
    }
    
    private func startGame(){
        statusManager.printAll()
        print("StartGame!")
        statusManager.setStartTimeNow()
        timeManager.startTimer()
        statusManager.printAll()
    }
    
    private func endGame() {
        print("EndGame!")
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
