//
//  TracksTableViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 17/10/23.
//

// #TODO: Gestire altri casi di autorizzazione location, anche durante game, compreso perdita segnale
// #TODO: popolare track
// #TODO: creare percorsi simulatore
// #TODO: gestione record
// #TODO: LABEL scheduledTime
// #TODO: gestione se scheduled con check time
// #TODO: creazione classe GameController?
// #TODO: rename APImanager in TrackAPImanager
// #TODO: BIG: QUIZ
// #TODO: BIG: QRCODESCANNER
// #TODO: BIG: DOCUMENTAZIONE


import UIKit

class TracksTableViewController: UITableViewController {

    var tracks: [Track] = []
    var trackNames :[String] = []
    let statusManager = StatusManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        print("#############")
        print("# APP START #")
        print("#############")
        
        // Creare un'istanza del TrackAPIManager
        let trackAPIManager = TrackAPIManager.shared
                
        // Eseguire l'operazione asincrona all'interno del blocco "async"
        Task {
            do {
                let tracks = try await trackAPIManager.getAllTracks()
                //trackAPIManager.printTracksData()
                
                // Assegna direttamente i dati delle tracce all'array tracks
                     self.tracks = tracks
                
                // Aggiornare l'UI sulla coda principale
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Errore nel recupero dei dati delle tracce: \(error)")
            }
        }
        checkStatus()
        
        print("currentTrack: \(statusManager.getStatusPropString(key: "currentTrackId"))")
        
        tableView.reloadData() //è quella di default di tutti i tableviewcontroller
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func checkStatus() {
        statusManager.printAll()
        // #TODO: se non nullo, va a mappa con track giusta
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // il return sarà la count dell'array
        //return tracks.count
        return tracks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackTableViewCell
        
        //conversione forzata a TrackTableViewCell
        
        // Configure the cell...
        //l'elemento alla posizione 0 sarà il primo percorso
        // la tableview è come un array a una dimensione, noi faremo una corrispondenza diretta
        // questo metodo viene chiamato da solo dalla did load
        
        //let track = tracks[indexPath.row]
        let track = tracks[indexPath.row] // Accedi all'oggetto Track corrispondente all'indice, il .row è l'indice della riga
        cell.titleLabel.text = track.name // Imposta la text label con la proprietà "name" dell'oggetto Track
        
        //cell.kidLabel.text = "ciao"
        
        // Imposta l'immagine in base a isKid (questo è un esempio, ma dovresti lavorare con l'oggetto Track per ottenere questa informazione)
        
       
        if track.isKid {
            // Se isKid è true, assegna l'immagine "figure.and.child.holdinghands" a cell.kidImageView
            cell.kidFlag.isHidden = false
            //let isKidString = track.isKid ? "true" : "false"
            //print(track.name + "-" + isKidString )
        } else {

            cell.kidFlag.isHidden = true
        }
        
        if track.isQuiz {
            // Se isKid è true, assegna l'immagine "figure.and.child.holdinghands" a cell.kidImageView
            cell.quizFlag.isHidden = false
            //let isQuizString = track.isQuiz ? "true" : "false"
            //print(track.name + "-" + isQuizString )
        } else {

            cell.quizFlag.isHidden = true
        }
                        
        //cell.quizFlag.image = UIImage(named: "figure.and.child.holdinghands")
        
        return cell
    }
               

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row] // Accedi all'oggetto Track corrispondente all'indice
        self.performSegue(withIdentifier: "toTrackDetails", sender: track)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let track = sender as! Track // specifico che sender è un Track e ne sono sicuro (non posso modificare sopra "Any?"
        let destController = segue.destination as! TrackDetailsViewController // lo forzo ad essere un TrackView
        destController.track = track
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // CLLocationManagerDelegate methods
/*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("sono in didUpdateLcoation è la posizione è  \(locationManager.location)")
    }
  */    

}
