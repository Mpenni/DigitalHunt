//
//  TrackDetailsViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//

import UIKit
import CoreLocation

class TrackDetailsViewController: UIViewController {
    
    var track = Track()

    override func viewDidLoad() {

        super.viewDidLoad()
        self.title = track.name
        descTextField.text = track.desc
        print("la desc selezionata è \(track.desc)" )
        let locationManager = LocationManager.shared
        var location = locationManager.locationManager.location
        
        print("La posizione è \(location?.coordinate.latitude)")
        
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
        
        
        
        if let sourceLocation = locationManager.locationManager.location, let firstNode = track.Nodes.first {
            // Creare un oggetto CLLocation per la posizione di destinazione utilizzando le coordinate del primo nodo
            let destinationLocation = CLLocation(latitude: firstNode.lat, longitude: firstNode.long)

            // Calcolare la distanza
            let distance = sourceLocation.distance(from: destinationLocation)
            
            distanceLabel.text = "La distanza dalla tua posizione attuale al percorso è di \(Int(distance)) metri"
        } else {
            distanceLabel.text = "Posizione attuale non disponibile o nessun nodo disponibile per calcolare la distanza."
        }
        
        



        // Do any additional setup after loading the view.
    }
    
    @IBAction func startGameAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toHuntMapView", sender: track)
    }

    @IBOutlet weak var descTextField: UITextView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var isKidIcon: UIImageView!
    
    @IBOutlet weak var isKidLabel: UILabel!
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let track = sender as! Track // specifico che sender è un Track e ne sono sicuro (non posso modificare sopra "Any?"
        let destController = segue.destination as! HuntMapViewController // lo forzo ad essere un TrackView
        destController.track = track
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
