//
//  APImanager2.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//

import Foundation
import FirebaseFirestore

class TrackAPIManager {
    static let shared = TrackAPIManager()
    let timeManager = TimeManager.shared
    
    private let showLog: Bool = true


    
    private init() {}
    
    var tracks: [Track] = [] // Array per archiviare le tracce
    
    // Funzione asincrona per recuperare tutti i tracks da Firebase
    func getAllTracks() async throws -> [Track] {
        let db = Firestore.firestore()
        
        // Utilizza "await" per aspettare il risultato dell'operazione Firebase
        let querySnapshot = try await db.collection("tracks").getDocuments()
        if showLog { print("TrackAPIMan - dimensione risultato query: \(querySnapshot.documents.count)") }

        
        var fetchedTracks: [Track] = [] // Crea un array temporaneo per le tracce
        
        
        
        for document in querySnapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String, // Verifica se "name" è una stringa
               let desc =  data["desc"] as? String,
               let isKid = data["isKid"] as? Bool,
               let isQuiz = data["isQuiz"] as? Bool,
               let idNodes = data["idNodes"] as? [String] {  //per essere valido, il track deve avere almeno un nodo.
               
                let id = document.documentID
                //let idNodes = data["idNodes"] as? [String] ?? [] // Leggi l'array "idNodes" con un valore predefinito vuoto
                let scheduledStart = timeManager.getDateFromString(data["scheduledStart"] as? String)
                let scheduledEnd = timeManager.getDateFromString(data["scheduledEnd"] as? String)
                let recordUserId = data["recordUserId"] as? String
                let recordUserTime = data["recordUserTime"] as? Int
                
                // Recupero i dati dei nodes associati ai track
                let nodes = try await getNodesForTrack(idNodes: idNodes)
                
                // Crea un oggetto "Track" utilizzando i dati ottenuti da Firebase
                let track = Track(id: id, name: name, desc: desc, nodes: nodes, isKid: isKid, isQuiz: isQuiz, scheduledStart: scheduledStart, scheduledEnd: scheduledEnd, recordUserId: recordUserId, recordUserTime: recordUserTime)
                fetchedTracks.append(track)
            } else {
                if showLog { print("TrackAPIMan - il track \(data["name"] ?? "nd") è stato scartato perchè non soddisfa le condizioni di base") }
            }
        }
        
        // Aggiorna l'array delle tracce con i dati appena ottenuti
        self.tracks = fetchedTracks
        
        if showLog { print("TrackAPIMan - dimensione finale risultato: \(tracks.count)") }
        
        // Restituisci l'array delle tracce
        return fetchedTracks
    }
    
    // Funzione asincrona per recuperare i dati dei nodes associati ai track
    private func getNodesForTrack(idNodes: [String]) async throws -> [Node] {
        if showLog { print("TrackAPIMan - richiesto dettaglio per \(idNodes.count) nodi") }
        let db = Firestore.firestore()
        var nodes: [Node] = []
        
        for nodeId in idNodes {
            let nodeDocument = try await db.collection("nodes").document(nodeId).getDocument()
            if let data = nodeDocument.data() {
                let node = Node(id: nodeDocument.documentID, data: data)
                nodes.append(node)
            }
        }
        if showLog { print("TrackAPIMan - restituito dettaglio per \(nodes.count) nodi") }
        return nodes
    }
    
    // Funzione per stampare ciclicamente i dati delle tracce nell'array
    func printTracksData() {
        for track in tracks {
            //print("Track ID: \(track.id)")
            print("Name: \(track.name)")
            print("Desc: \(track.desc)")
            print("Is Kid: \(track.isKid)")
            print("Is Quiz: \(track.isQuiz)")

            if !track.Nodes.isEmpty {
                print("Nodes:")
                for node in track.Nodes {
                    //print("Node ID: \(node.id)")
                    print("      Name: \(node.name)")
                    print("      Latitude: \(node.lat)")
                    print("      Longitude: \(node.long)")
                }
            } else {
                print("No Nodes for this track.")
            }

        }
    }

}

