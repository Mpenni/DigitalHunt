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
    var currentNode: Node?  //#TODO non è meglio usare solo track.nodes[currentNodeIndex]?
    var isStart: Bool = false
    var isEnd: Bool = false
    var coordinates :CLLocationCoordinate2D?
    var distance: Int = -1
    var userIsInsideNode : Bool = false
    var areaCircle: MKCircle?
    var nodePin: MKPointAnnotation?
       
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.title = track.name
        checkStatus()
        setupBackButton()
        locationManager.locationManager.delegate = self
        locationManager.locationManager.startUpdatingLocation()
        
        //updateLocationOnMap()
        
        timeManager.updateHandler = { [weak self] timeString in self!.timeLabel.text = timeString}
        print("finedidload")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userIsInsideNode = false

        print("inizioDidAppera")
        //print("NODOOOOO! \(currentNode?.name)")
        print("track.currennodeindex= \(track.currentNodeIndex)")

        

        currentNode = track.changeNode()
        statusManager.setStatusPropInt(key: "currentNodeIndex", value: track.currentNodeIndex)
        //incrementare status
        //print("NODOOOOO! \(currentNode?.name)")
        print("track.currennodeindex= \(track.currentNodeIndex)")
        //print("LAT in DIDAPPEAR \(currentNode?.lat)")
        statusManager.printAll()
        resetMarker()
        loadUserOnMap()
        drawAreaInMap()
        print("fineDidAppear")
    }
    
    private func checkStatus() {
        if statusManager.getStatusPropString(key: "currentTrackId") == nil {
            statusManager.setStatusPropString(key: "currentTrackId", value: track.id)
        }
        if let index = statusManager.getStatusPropInt(key: "currentNodeIndex") {
            track.setCurrentNodeIndex(index: index - 1) //viene poi incrementato
        }
    }
    
    
    
    
    private func loadUserOnMap() {
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
        print("start drawAreaInMap")
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
        //print("isStart \(isStart)")
        //print("isEnd \(isEnd)")
    }
    
   
    
    private func drawMarker() {
        nodePin = MKPointAnnotation()
        nodePin!.coordinate.latitude = currentNode!.lat
        nodePin!.coordinate.longitude = currentNode!.long
        if isStart {
            nodePin!.title = "INIZIO"
        } else if isEnd {
            nodePin!.title = "FINE"
        } else {
            nodePin!.title = "TAPPA \(track.currentNodeIndex + 1)"
        }
        //nodePin.subtitle = "Subtitle"
        mapView.addAnnotation(nodePin!)
        areaCircle = MKCircle(center: nodePin!.coordinate, radius: 10)
        mapView.addOverlay(areaCircle!)
    }
    
    private func resetMarker() {
        if let circle = areaCircle {
            mapView.removeOverlay(circle)
            areaCircle = nil
        }
        if let pin = nodePin {
            mapView.removeAnnotation(pin)
            nodePin = nil
        }
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
        print("sono in DID UPDATE LOCATION")
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
        if !userIsInsideNode {
            print("startCheckisIsnide")
            let radius = 10
            distance = locationManager.calculateDistanceFromHere(lat: currentNode!.lat, long: currentNode!.long)
            print("LATITUDE \(currentNode?.lat)")
            print("DISTANCE \(distance)")

            if distance < 0 {
                distanceLabel.text = "-nd-"
            } else if distance <= radius {
                distanceLabel.text = "0m"
                insideNode()
            } else {
                distanceLabel.text = "\(distance-10)m"
            }
        }
    }
    
    private func insideNode(){
        //check is not quiz + SCHEDULED TIME
        print("INSIDE NODE!")
        userIsInsideNode = true
        infoLabel.text = "Hai raggiunto la destinazione"  //x debug
        if isEnd {
            endGame()
            return
        } else
        if isStart {
            startGame()
        }
        //per scopi di debug:
        if track.isQuiz {
            self.performSegue(withIdentifier: "toQuizView", sender: track)
        } else {
            self.performSegue(withIdentifier: "toQRCodeView", sender: track)

        }
        // se is quiz false -> lettura/inserimento QRCODE
        
        
        //currentNode = track.changeNode()
        //print("Curren Node inddex: \(track.currentNodeIndex)")
        //drawAreaInMap()
        // l'incremento dell'index node lo faccio al termine del quiz
    }
    
    private func startGame(){
        //statusManager.printAll()
        print("StartGame!")
        if statusManager.getStatusPropString(key: "startTime") == nil {
            statusManager.setStartTimeNow()
        }
        timeManager.startTimer()
        //statusManager.printAll()
    }
    
    private func endGame() {
        print("EndGame!")
        statusManager.resetStatus()
        // #TODO: stop timer
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
            self.timeManager.stopTimer()
            self.navigationController?.popViewController(animated: true)
        })
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        ac.addAction(yes)
        ac.addAction(no)
        self.present(ac, animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuizView" {
            let track = sender as! Track // specifico che sender è un Track e ne sono sicuro (non posso modificare sopra "Any?"
            let destController = segue.destination as! TriviaController // lo forzo ad essere un TrackView
            destController.track = track
        } else if segue.identifier == "toQRCodeView" {
            let track = sender as! Track // specifico che sender è un Track e ne sono sicuro (non posso modificare sopra "Any?"
            //let destController = segue.destination as! QRCodeController // lo forzo ad essere un TrackView
            //destController.track = track
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
