//
//  TracksTableViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 17/10/23.
//

// #TODO: Gestire altri casi di autorizzazione location, anche durante game, compreso perdita segnale
// #TODO: popolare track
// #TODO: creare percorsi simulatore
// #TODO: BIG: QRCODESCANNER +  spostare man uale sopra
// #TODO: BIG: DOCUMENTAZIONE

// in code NON uscire da app (forse anche in game), ma resettare

import UIKit

class TracksTableViewController: UITableViewController {

    var tracks: [Track] = []
    var trackNames :[String] = []
    let trackAPIManager = TrackAPIManager.shared
    
    private let showLog: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        print("#############")
        print("# APP START #")
        print("#############")

        //print("UNIQUE_DEL: \(statusManager.deleteUserUniqueId())") //per debug
        
        // Eseguo l'operazione asincrona all'interno del blocco "async"
        Task {
            do {
                var allTracks = try await trackAPIManager.getAllTracks()
                if showLog { print("TTC - chiamo  'trackAPIManager.getAllTracks()'")}

                //trackAPIManager.printTracksData()
                
                if showLog {
                    for track in allTracks {
                        print("TTC - Track ID: \(track.id)")
                        print("    -> TrackName: \(track.name)")
                        print("    -> Desc: \(track.desc)")
                        print("    -> Is Kid: \(track.isKid)")
                        print("    ->Is Quiz: \(track.isQuiz)")
                        print("    ->Is scheduledStart: \(String(describing: track.scheduledStart))")
                        print("    ->Is scheduledEnd: \(String(describing: track.scheduledEnd))")
                         if !track.Nodes.isEmpty {
                         print("    ->Nodes:")
                         for node in track.Nodes {
                         //print("Node ID: \(node.id)")
                         print("          ->Name: \(node.name)")
                         print("          ->Latitude: \(node.lat)")
                         print("          ->Longitude: \(node.long)")
                         }
                         } else {
                         print("          ->No Nodes for this track.")
                         }
                    }
                }
                
                if showLog { print("TTC - Lunghezza tracks prima del filtro: \(allTracks.count)") }
                
                if showLog { print("TTC - Applico filtro a tracks") }
                allTracks = allTracks.filter { track in
                    track.Nodes.count >= 2 &&
                    (track.isQuiz || (track.scheduledStart != nil && track.scheduledEnd != nil))
                }
                if showLog { print("TTC - Lunghezza tracks dopo filtro: \(allTracks.count)")}

                // Ordino l'array
                allTracks.sort { $0.name < $1.name } // $x elementi di  chiusura di ordinamento (primo elem, secondo elem da confrontare)
                
                // Assegno direttamente i dati delle tracce all'array tracks
                tracks = allTracks
                
                // Aggiorno l'UI sulla coda principale
                // con task sposto (asincronicamente con await) esecuzione in altro thread, ma solo con il main ho il permesso di modifuca UI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("ERROR TTC - Errore nel recupero dei dati delle tracce: \(error)")
            }
        }
        
        /*  // non è deterministico, valutare con un calo di connessione
        tableView.reloadData() //è quella di default di tutti i tableviewcontroller //#TODO: verificare se necessario ripeterla
        */
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        if showLog { print("TTC - creo riga \(indexPath.row + 1)") }
        
        // Configure the cell...
        // l'elemento alla posizione 0 sarà il primo percorso
        // la tableview è come un array a una dimensione, noi faremo una corrispondenza diretta
        // questo metodo viene chiamato da solo dalla did load
        
        let track = tracks[indexPath.row] // Accedi all'oggetto Track corrispondente all'indice, il .row è l'indice della riga
        
        cell.titleLabel.text = track.name
       
        if track.isKid {
            cell.kidFlag.isHidden = false
        } else {
            cell.kidFlag.isHidden = true
        }
        
        if track.isQuiz {
            cell.quizFlag.isHidden = false
        } else {
            cell.quizFlag.isHidden = true
        }
                        
        return cell
    }
               
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row] // Accedi all'oggetto Track corrispondente all'indice
        if showLog { print("TTC - goToTrackDetails per riga \(indexPath.row + 1)") }
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
        let track = sender as! Track // specifico che sender è un Track e ne sono sicuro
        let destController = segue.destination as! TrackDetailsViewController // lo forzo ad essere un TrackView
        destController.track = track
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
