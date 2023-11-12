//
//  HuntMapViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//  45.5 9.08

import UIKit
import CoreLocation
import MapKit

class HuntMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var legLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var track = Track()
    let locationManager = DHLocationManager.shared
    let statusManager = StatusManager.shared
    let timeManager = TimeManager.shared
    let configManager = ConfigManager.shared

    
    var currentNode: Node?
    var isStart: Bool = false
    var isEnd: Bool = false
    var distance: Int = -1
    var userIsInsideNode : Bool = false
    var setupComplete: Bool = false
    
    //Variabili di Mappa e Posizione
    var coordinates :CLLocationCoordinate2D?
    var areaCircle: MKCircle?
    var nodePin: MKPointAnnotation?
    var radius: Int = 10
    
    private let showLog: Bool = true

    override func viewDidLoad() {
        if showLog { print("HMapC - inizio 'viewDidLoad'")}

        super.viewDidLoad()
        mapView.delegate = self
        self.title = track.name
        
        checkStatus()  // verifico la presenza di uno status per permettere il ripristino di una partita interrotta
        
        setupBackButton()  //assegno al backButton comportamento personalizzato
        
        setConfig()  // carico la configurazione

        locationManager.locationManager.delegate = self
        
        locationManager.locationManager.startUpdatingLocation()
        
        setupUserTrackingButtonAndScaleView()  // implemento il bottone "seguimi" e la scala in legenda
        
        if showLog { print("HMapC - fine 'viewDidLoad'")}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if showLog { print("HMapC - inizio 'viewDidAppear'")}
        
        super.viewDidAppear(animated)

        setupComplete = false

        userIsInsideNode = false

        timeManager.updateHandler = { [weak self] timeString in self!.timeLabel.text = timeString}   //update del timer con handler invocato da TimeManager (gli passo una funzione anonima istanziata e chiamata da TimeManager)

        if showLog { print("HMapC - track.currennodeindex= \(track.currentNodeIndex)")}
        
        // incremento di uno il valore dell'indice del nodo corrente
        currentNode = track.changeNode()
        if showLog { print("HMapC - lancio 'track.changeNode()'")}
       
        // setto il nuovo valore nello status, per permettere il resume del game
        statusManager.setStatusProp(key: "currentNodeIndex", value: "\(track.currentNodeIndex)")
        if showLog { print("HMapC - track.currennodeindex e status = \(track.currentNodeIndex)")}

        //carico i dettagli grafici della mappa
        loadUserOnMap()
        drawAreaInMap()

        setupComplete = true
        if showLog { print("HMapC - fine 'viewDidAppear'")}
    }

    
    private func setConfig() {
        if  let confRadius = configManager.getValue(forKey: "map.radius") as? Int {
            if showLog { print("HMapC - load radius from config: \(confRadius)")}
            radius = confRadius
        }
    }
    
    private func checkStatus() {
        if showLog { print("HMapC - lanciato 'checkStatus()'")}
        //setto STATUS currentTrackId se nil
        if statusManager.getStatusProp(key: "currentTrackId") == nil {
            statusManager.setStatusProp(key: "currentTrackId", value: track.id)
            
            if showLog { print("HMapC - Status.currentTrackId è nil, lo setto a : \(track.id)")}
            if showLog { print("         -> (primo accesso)")}
        }
        
        //setto track.currentNodeIndex se STATUS currentNodeIndex non è nullo
        if let indexString = statusManager.getStatusProp(key: "currentNodeIndex"), let index = Int(indexString) {
            track.setCurrentNodeIndex(index: index - 1)
            
            if showLog { print("HMapC - Status.ccurrentNodeIndex non è nil, setto 'track.currentNodeIndex a suo valore meno uno' : \(index - 1)")}
        }
        
        //se l'utente ha raggiunto l'inizio, ma non ha concluso la tappa, il timer è partito e va visualizzato
        if statusManager.getStatusProp(key: "startTime") != nil {
            timeManager.startTimer()
        }
        
    }
    
    private func defineTargetNode() {
        //definisco nodo corrente e definisco se è un nodo speciale (Start/End)
        currentNode = track.getCurrentNode()
        if showLog { print("HMapC - defineTargetNode(): setto 'currentNode' = \(currentNode?.desc ?? "desc node nd")")}
        
        isStart = track.checkIsStartNode()
        isEnd = track.checkIsEndNode()
    }

    private func updateLabels() { //legLabel & infoLabel
        if showLog { print("HMapC - setto infoLabel e LegLabel")}
        legLabel.text = "\(track.currentNodeIndex) di \(track.nodes.count - 1)"
        if track.checkIsStartNode() {
            infoLabel.text = "Procedi verso l'area 'INIZIO'"
        } else {
            infoLabel.text = "Procedi verso la prossima area"
            timeManager.startTimer()
            if showLog { print("HMapC - richiamo timer (se NON sono in start, per resume game")}
        }
    }
       
    private func checkIsInsideNode() {
        //Calcolo la distanza tra l'utente e area di trigger di un nodo, e se è all'interno, lancio insideNode()
        if showLog { print("HMapC - 'checkIsInsideNode()'")}

        if !userIsInsideNode && setupComplete {  //aspetto il completamento del setup prima di iniziare il check
            distance = locationManager.calculateDistanceFromHere(lat: currentNode!.lat, long: currentNode!.long)

            if showLog { print("HMapC - 'checkIsInsideNode()', calcolo distanza: \(distance)")}
            if distance < 0 {
                distanceLabel.text = "-nd-"
            } else if distance <= radius {
                distanceLabel.text = "0m"
                insideNode()
            } else {
                distanceLabel.text = "\(distance-radius)m"
            }
        }
    }
    
    private func insideNode(){
        // gestisce l'arrivo dell'utente all'interno del nodo e devia il flusso in base al tipo di percorso (assistito/non assistito)
        
        if showLog { print("HMapC - 'insideNode()'")}
        userIsInsideNode = true
        infoLabel.text = "Hai raggiunto la destinazione"
        if isEnd {
            endGame()
            return
        } else
        if isStart {
            startGame()
        }
        if track.isQuiz {
            self.performSegue(withIdentifier: "toQuizView", sender: track)
        } else {
            self.performSegue(withIdentifier: "toQRCodeView", sender: track)
        }
    }
    
    private func startGame(){
        // Inizia formalmente il gioco: viene settato il dateTime attuale come quello di partenza e faccio partire il timer
        if showLog { print("HMapC - 'startGame()'")}
        if statusManager.getStatusProp(key: "startTime") == nil {
            statusManager.setStartTimeNow()
            timeManager.startTimer()
            if showLog { print("HMapC - startTime in STATUS è nil -> lancio 'statusManager.setStartTimeNow()'")}
            if showLog { print("HMapC - startTime in STATUS è nil -> lancio 'timeManager.startTimer()'")}
        }
    }
    
    private func endGame() {
        // Finisce formalmente il gioco: si calcola il proprio tempo, si ferma il timer, si ferma la localizzazione e si naviga alla pagina finale.
        if showLog { print("HMapC - 'endGame()' -> resetStatus, stopTimer")}
        statusManager.setMyTotalGameTime()
        timeManager.stopTimer()
        if showLog { print("HMapC - 'endGame()' -> stop updating location")}
        locationManager.locationManager.stopUpdatingLocation()
        self.performSegue(withIdentifier: "toEndView", sender: track)
    }
 
    
    // MARK: - Navigation

    func setupBackButton(){
        if showLog { print("HMapC - 'setupBackButton()'")}
        
        let newBackButton = UIBarButtonItem(title: "Annulla", style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = newBackButton
    }

    @objc func back(_ sender: UIBarButtonItem?) {
        if showLog { print("HMapC - sono in func 'back'")}

        navigationItem.hidesBackButton = true
        let ac = UIAlertController(title: "Annullare la gara in corso? Questa azione cancellerà tutti i tuoi progressi", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Si", style: .destructive, handler: { action in
            if self.showLog { print("HMapC - Annullo gara in corso'")}

            self.statusManager.resetStatus()
            if self.showLog { print("     -> resetStatus")}
            
            self.track.setCurrentNodeIndex(index: -1)
            if self.showLog { print("     -> setCurrentNodeIndex in track a -1")}

            self.timeManager.stopTimer()
            if self.showLog { print("     -> stopTimer")}

            if self.showLog { print("HMapC - effettuo navigazione back")}
            self.navigationController?.popViewController(animated: true)
        })
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        ac.addAction(yes)
        ac.addAction(no)
        self.present(ac, animated: true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toQuizView" {
            let track = sender as! Track // specifico che sender è un Track
            let destController = segue.destination as! TriviaController // lo forzo ad essere un TriviaController
            destController.track = track
            
        } else if segue.identifier == "toQRCodeView" {
            let track = sender as! Track
            
            let destController = segue.destination as! QRCodeController // lo forzo ad essere un QRCodeController
            destController.track = track
            
        } else if segue.identifier == "toEndView" {
            let track = sender as! Track
            
            let destController = segue.destination as! EndPageController // lo forzo ad essere un EndPageController
            destController.track = track
        }
    }
}

// MARK: - Maps


extension HuntMapViewController: MKMapViewDelegate {
    // Funzioni delegate di MKMapView e specifiche di disegno e gestione della mappa
    
    // Funzione 'rendererFor', usata per disegnare l'overlay del cerchio (render)
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         if self.showLog { print("HMapC - sono in 'renderFor")}
         if let circleOverlay = overlay as? MKCircle {  //se overlay è MKCircle
             let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
             circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
             circleRenderer.strokeColor = UIColor.blue
             circleRenderer.lineWidth = 1
             return circleRenderer
         }
         return MKOverlayRenderer(overlay: overlay)
     }
    
    private func drawAreaInMap() {
        if self.showLog { print("HMapC - sono in 'drawAreaInMap()'")}
        defineTargetNode()
        updateLabels()
        drawMarker()
        
        // Chiamo showAnnotations per impostare il livello di zoom in modo da vedere tutti gli marker sulla mappa
        mapView.showAnnotations(mapView.annotations, animated: true)
        checkIsInsideNode()
    }
    
    private func drawMarker() {
        // disegno sulla mappa il marker del nodo corrente e l'area di trigger
        resetMarker()
        if self.showLog { print("HMapC - sono in 'drawMarker()'")}
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
        
        // aggiungo alla view l'area di trigger (il render lo farà il metodo delegato "RenderFor")
        areaCircle = MKCircle(center: nodePin!.coordinate, radius: CLLocationDistance(radius))
        mapView.addOverlay(areaCircle!)
    }
    
    private func resetMarker() {
        // rimuovo dalla mappa il marker/area attuale
        if self.showLog { print("HMapC - sono in 'resetMarker()'")}
        if let circle = areaCircle {
            mapView.removeOverlay(circle)
            areaCircle = nil
        }
        if let pin = nodePin {
            mapView.removeAnnotation(pin)
            nodePin = nil
        }
    }
    
    func setupUserTrackingButtonAndScaleView() {
        // aggiungo un bottone sulla mappa che gestisce la funzionalità di seguire l'utente.
        
        if showLog { print("LocMan - sono in 'setupUserTrackingButtonAndScaleView'")}
        mapView.showsUserLocation = true
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



// MARK: - Location

extension HuntMapViewController: CLLocationManagerDelegate {
    // Funzioni delegate di MKMapView e specifiche di localizzazione
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.showLog { print("HMapC - sono in 'didUpdateLocations'")}  
        //updateLocationOnMap()
        checkIsInsideNode()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR HMapC - Errore nell'aggiornamento della posizione: \(error.localizedDescription)")
    }
    
    //funzione precendete alla gestione dello zoom/centratura con button apposito (MKUserTrackingButton)
    private func updateLocationOnMap() {
        guard locationManager.locationManager.location != nil else {
            if self.showLog { print("HMapC - posizione non disponibile")}
                return
        }
        coordinates = locationManager.locationManager.location!.coordinate
        mapView.setCenter(coordinates!, animated: true)
    }
    
    private func loadUserOnMap() {
        if self.showLog { print("HMapC - sono in 'loadUserOnMap()'")}
        guard locationManager.locationManager.location != nil else {
                print("Posizione non disponibile.")
                return
        }
        mapView.setRegion(locationManager.calculateRegion(), animated: true)
        mapView.showsUserLocation = true
    
    }
}


