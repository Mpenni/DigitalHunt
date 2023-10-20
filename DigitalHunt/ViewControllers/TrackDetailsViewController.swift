//
//  TrackDetailsViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//

import UIKit

class TrackDetailsViewController: UIViewController {
    
    var track = Track()

    override func viewDidLoad() {

        super.viewDidLoad()
        self.title = track.name
        descTextField.text = track.desc
        print("la desc selezionata è \(track.desc)" )

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startGameAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toHuntMapView", sender: track)
    }

    @IBOutlet weak var descTextField: UITextView!
    
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
