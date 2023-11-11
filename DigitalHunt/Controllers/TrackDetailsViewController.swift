//
//  TrackDetailsViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//

import UIKit
import CoreLocation

class TrackDetailsViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var descTextField: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var isKidIcon: UIImageView!
    @IBOutlet weak var isKidLabel: UILabel!
    @IBOutlet weak var isQuizIcon: UIImageView!
    @IBOutlet weak var isQuizLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startLabelInfo: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endLabelInfo: UILabel!
    
    var track = Track()
    let locationManager = DHLocationManager.shared
    let timeManager = TimeManager.shared
    let statusManager = StatusManager.shared
    
    private let showLog: Bool = true

    override func viewDidLoad() {
        if showLog { print("TDetailsC - sono in 'viewDidLoad()'")}
        super.viewDidLoad()
        //ErrorManager.showError(view: self, message: "messaggio", gotoRoot: true)
        self.title = track.name
        descTextField.text = track.desc
        manageLocation()
        setIcons()
    }
    
    private func setIcons() {
        if showLog { print("TDetailsC - sono in 'setIcons()'")}

        if track.isKid {
            isKidIcon.isHidden = false
            isKidLabel.isHidden = false
        } else {
            isKidIcon.isHidden = true
            isKidLabel.isHidden = true
        }
        if !track.isQuiz {
            populateIsNotQuiz()
        }
    }
    
    private func populateIsNotQuiz(){
        if showLog { print("TDetailsC - sono in 'populateIsNotQuiz()'")}

        isQuizIcon.isHidden = true
        isQuizLabel.isHidden = true
        
        startLabelInfo.isHidden = false
        endLabelInfo.isHidden = false
        startLabel.isHidden = false
        endLabel.isHidden = false
        
        startLabel.text = timeManager.getStringFromDate(track.scheduledStart) ?? "-nd-"
        endLabel.text = timeManager.getStringFromDate(track.scheduledEnd) ?? "-nd-"
        
        //se non è QUIZ, devo controllare le date
        checkDates()
    }
    
    private func checkDates() {
        if showLog { print("TDetailsC - sono in 'checkDates()'")}

        let currentDate = Date()
        if showLog { print("          -> currentDate   : \(currentDate)")}
        if showLog { print("          -> scheduledStart: \(String(describing: track.scheduledStart))")} //(describing per silenziare warning in quanto optional)
        if showLog { print("          -> scheduledEnd  : \(String(describing: track.scheduledStart))")}

        if track.scheduledStart! > currentDate || track.scheduledEnd! < currentDate {
            startButton.isEnabled = false
            if showLog { print("TDetailsC - disabilito tasto 'START'")}
        }
    }
    @IBAction func startGameAction(_ sender: Any) {
        if showLog { print("TDetailsC - sono in 'startGameAction'")}
        //se esiste un trackId nello Status e non coincide con quello selezionato -> Alert
        if let statusTrackId = statusManager.getStatusProp(key: "currentTrackId"),
           statusTrackId != track.id {
            let alertController = UIAlertController(
                title: "Start the game?",
                message: "Starting the game will erase all your progress. Do you want to continue?",
                preferredStyle: .alert
            )
            
            let continueAction = UIAlertAction(title: "Continue", style: .destructive) { [weak self] _ in  // funzione anonima che passo come parametro (closure)
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let track = sender as! Track // specifico che sender è un Track e ne sono sicuro
        let destController = segue.destination as! HuntMapViewController // lo forzo ad essere un TrackView
        destController.track = track
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

// MARK: - Location

extension TrackDetailsViewController: CLLocationManagerDelegate {
    // metodi CLLocationManagerDelegate  e altri specifiche di localizzazione

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        setupLocation()
    }
 
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if showLog { print("TDetailsC - Controllo Autorizzazioni Location")}
        locationManager.checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    private func manageLocation() {
        if showLog { print("TDetailsC - Sono in 'manageLocation'")}
        locationManager.locationManager.delegate = self
        locationManager.requestAuthorization()
        locationManager.locationManager.startUpdatingLocation()
        setupLocation()
    }
    
    private func calculateDistanceFromHere() {
        var distance :Int
        distance = locationManager.calculateDistanceFromHere(lat: track.nodes.first!.lat, long: track.nodes.first!.long)
        if distance >= 0 {
            distanceLabel.text = "La distanza dalla tua posizione attuale al percorso è di \(distance) metri"
        } else {
            distanceLabel.text = "Posizione attuale non disponibile o nessun nodo disponibile per calcolare la distanza."
        }
        
    }
    
    private func setupLocation() {
        if showLog { print("TDetailsC - sono in setupLocation")}
        if (locationManager.locationManager.location != nil)  {
            if showLog { print("TDetailsC - 'setupLocation': la posizione è valida")}
            calculateDistanceFromHere()
        } else {
            if showLog { print("TDetailsC - 'setupLocation': non c'è una posizione valida")}
        }
    }
}
