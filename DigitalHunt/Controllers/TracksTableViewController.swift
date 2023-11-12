//
//  TracksTableViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 17/10/23.
//


import UIKit

class TracksTableViewController: UITableViewController {

    var tracks: [Track] = []
    let trackAPIManager = TrackAPIManager.shared
    
    private let showLog: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("#############")
        print("# APP START #")
        print("#############")

        //print("UNIQUE_DEL: \(statusManager.deleteUserUniqueId())") //per debug
        
        // Eseguo l'operazione asincrona all'interno del blocco "async" per recuperare i tracks
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
                         if !track.nodes.isEmpty {
                         print("    ->Nodes:")
                         for node in track.nodes {
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
                    track.nodes.count >= 2 &&
                    (track.isQuiz || (track.scheduledStart != nil && track.scheduledEnd != nil))
                }
                if showLog { print("TTC - Lunghezza tracks dopo filtro: \(allTracks.count)")}

                // Ordino l'array in ordine alfabetico
                allTracks.sort { $0.name < $1.name } // $x elementi di  chiusura di ordinamento (primo elem, secondo elem da confrontare)
                
                tracks = allTracks
                
                // Aggiorno l'UI sulla coda principale
                // (con task ho spostato, asincronicamente con await, l'esecuzione in altro thread, ma solo con il main ho il permesso di modifuca UI)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("ERROR TTC - Errore nel recupero dei dati delle tracce: \(error)")
                ErrorManager.showError(view: self, message: "Purtroppo attualmente il servizio è in manutenzione. Riprovare più tardi", gotoRoot: true)
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //numero delle sezioni
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // numero delle righe (celle)
        // il return sarà la count dell'array (= numero di righe)
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackTableViewCell      //conversione forzata a TrackTableViewCell
        
        //Metodo chiamato in automatico dalla UITableViewController per popolare ogni cella
        
        if showLog { print("TTC - creo riga \(indexPath.row + 1)") }
        
        let track = tracks[indexPath.row] // Accedi all'oggetto Track corrispondente all'indice, il .row è l'indice della riga
        
        //popolo i 3 elementi della view della cella
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
        let track = tracks[indexPath.row] // Accedi all'oggetto Track corrispondente all'indice (click)
        if showLog { print("TTC - goToTrackDetails per riga \(indexPath.row + 1)") }
        self.performSegue(withIdentifier: "toTrackDetails", sender: track)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let track = sender as! Track // specifico che sender è un Track
        let destController = segue.destination as! TrackDetailsViewController // lo forzo ad essere un TrackViewController
        destController.track = track
    }
}
