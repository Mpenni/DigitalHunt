//
//  TrackDetailsViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//

import UIKit
import CoreLocation

class TrackDetailsViewController: UIViewController, CLLocationManagerDelegate {
    
    var track = Track()
    let locationManager = DHLocationManager.shared
    let timeManager = TimeManager.shared
    let statusManager = StatusManager.shared

    var distance :Int = -1

    //var location : CLLocation?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = track.name
        descTextField.text = track.desc
        locationManager.locationManager.delegate = self
        //print("la desc selezionata è \(track.desc)" )
        //locationManager.startUpdatingLocation()
        //location = locationManager.myCurrentlocation
        locationManager.requestAuthorization()
        locationManager.locationManager.startUpdatingLocation()
        setupLocation()


        //print("La posizione è \(location?.coordinate.latitude)")
        
        if track.isKid {
            // Se isKid è true, assegna l'immagine "figure.and.child.holdinghands" a cell.kidImageView
            isKidIcon.isHidden = false
            isKidLabel.isHidden = false
            //let isKidString = track.isKid ? "true" : "false"
            //print(track.name + "-" + isKidString )
        } else {
            isKidIcon.isHidden = true
            isKidLabel.isHidden = true
        }
        
        if !track.isQuiz {
            populateIsNotQuiz()
        }
        
        // se not game disable button if not in range
    }
    
    /*
    @IBAction func startGameAction(_ sender: Any) {

        self.performSegue(withIdentifier: "toHuntMapView", sender: track)
    }
    */
    
    @IBAction func startGameAction(_ sender: Any) {
        //se esiste un trackId nello Status e non coincide con quello selezionato -> Alert
        if let statusTrackId = statusManager.getStatusProp(key: "currentTrackId"),
           statusTrackId != track.id {
            let alertController = UIAlertController(
                title: "Start the game?",
                message: "Starting the game will erase all your progress. Do you want to continue?",
                preferredStyle: .alert
            )
            
            let continueAction = UIAlertAction(title: "Continue", style: .destructive) { [weak self] _ in
                //resetto lo status e procedo
                self!.statusManager.resetStatus()
                self!.performSegue(withIdentifier: "toHuntMapView", sender: self!.track)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(continueAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "toHuntMapView", sender: track)
        }
    }


    
    @IBOutlet weak var descTextField: UITextView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var isKidIcon: UIImageView!
    
    @IBOutlet weak var isKidLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var startLabelInfo: UILabel!
        
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var endLabelInfo: UILabel!
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let track = sender as! Track // specifico che sender è un Track e ne sono sicuro (non posso modificare sopra "Any?"
        let destController = segue.destination as! HuntMapViewController // lo forzo ad essere un TrackView
        destController.track = track
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    private func populateIsNotQuiz(){
        startLabelInfo.isHidden = false
        endLabelInfo.isHidden = false
        startLabel.isHidden = false
        endLabel.isHidden = false
        startLabel.text = timeManager.getStringFromDate(track.scheduledStart) ?? "-nd-"
        endLabel.text = timeManager.getStringFromDate(track.scheduledEnd) ?? "-nd-"
        checkDates()
        
        
        
    }
    
    private func checkDates() {
        let currentDate = Date()
        print (currentDate)
        print ("start \(track.scheduledStart!)")
        print ("end \(track.scheduledEnd!)")

        if track.scheduledStart! > currentDate || track.scheduledEnd! < currentDate {
            startButton.isEnabled = false
            print("disabilito tasto start")
        }
    }
    
    
    private func setupLocation() {

        if (locationManager.locationManager.location != nil)  {
            print("Posizione Corrente (TrackDetails-didUpdateLocation): \(locationManager.locationManager.location?.coordinate.latitude) \(locationManager.locationManager.location?.coordinate.latitude)")
            //print("La posizione è \(locationManager.locationManager.location?.coordinate.latitude)")
            calculateDistanceFromHere()
        } else {
            print("Non ho trovato posizione")
        }
        
    
    }
    
    func calculateDistanceFromHere() {
        distance = locationManager.calculateDistanceFromHere(lat: track.Nodes.first!.lat, long: track.Nodes.first!.long)
        if distance >= 0 {
            distanceLabel.text = "La distanza dalla tua posizione attuale al percorso è di \(distance) metri"
        } else {
            distanceLabel.text = "Posizione attuale non disponibile o nessun nodo disponibile per calcolare la distanza."
        }
        
    }
    
    /*
    func calculateDistanceFromHere2() {
        //print("LM: \(locationManager.locationManager.location)")
        //print("FN: \(track.Nodes.first)")
        if let sourceLocation = locationManager.locationManager.location, let firstNode = track.Nodes.first {
        
            
            let destinationLocation = CLLocation(latitude: firstNode.lat, longitude: firstNode.long)

            // Calcolare la distanza
            let distance = sourceLocation.distance(from: destinationLocation)
            
            distanceLabel.text = "La distanza dalla tua posizione attuale al percorso è di \(Int(distance)) metri"
        } else {
            distanceLabel.text = "Posizione attuale non disponibile o nessun nodo disponibile per calcolare la distanza."
        }
  
    }
     */
    
    
    // CLLocationManagerDelegate methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("sono in didUpdateLcoation")
        setupLocation()
    }
 
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Controllo Autorizzazioni Location (TrackDetails)")
        locationManager.checkLocationAuthorization()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}
