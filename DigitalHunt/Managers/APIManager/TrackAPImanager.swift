//
//  TrackAPIManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//
// Questo manager serve a recuperare i percorsi (tracks) dal cloud

import Foundation
import FirebaseFirestore

class TrackAPIManager {
    static let shared = TrackAPIManager()
    let timeManager = TimeManager.shared
    
    private let showLog: Bool = true

    private init() {}
    
    var tracks: [Track] = []
    
    // Funzione asincrona per recuperare tutti i tracks da Firebase
    func getAllTracks() async throws -> [Track] {
        let db = Firestore.firestore()
        
        // Utilizza "await" per aspettare il risultato dell'operazione Firebase
        let querySnapshot = try await db.collection("tracks").getDocuments()
        if showLog { print("TrackAPIMan - dimensione risultato query: \(querySnapshot.documents.count)") }

        var fetchedTracks: [Track] = [] // Crea un array temporaneo per le tracce
        
        for document in querySnapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String, // Verifica se "name" esiste ed è una stringa
               let desc =  data["desc"] as? String,
               let isKid = data["isKid"] as? Bool,
               let isQuiz = data["isQuiz"] as? Bool,
               let idNodes = data["idNodes"] as? [String] {  //per essere valido, il track deve avere almeno un nodo.
                let id = document.documentID
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
    
    // Funzione per stampare ciclicamente i dati delle tracce nell'array (x debug)
    func printTracksData() {
        for track in tracks {
            print("Name: \(track.name)")
            print("Desc: \(track.desc)")
            print("Is Kid: \(track.isKid)")
            print("Is Quiz: \(track.isQuiz)")

            if !track.nodes.isEmpty {
                print("Nodes:")
                for node in track.nodes {
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
    
    func updateTrackRecordData(trackId: String, recordUserId: String, recordUserTime: Int) async throws {
        //persisto il nuovo record di tempo a DB
        let db = Firestore.firestore()
        
        var data: [String: Any] = [
            "recordUserId": recordUserId,
            "recordUserTime": recordUserTime
        ]
        
        do {
            // Prova a recuperare il documento track esistente nel database
            var existingData = try await db.collection("tracks").document(trackId).getDocument().data()
            
            // Se esiste già un documento, unisce i dati esistenti con i nuovi dati
            if existingData != nil {
                existingData!.merge(data) { (current, new) in new }
                data = existingData!
            }
            
            // Aggiorna o inserisce il documento track con i nuovi dati
            try await db.collection("tracks").document(trackId).setData(data)
            
            print("Dati track aggiornati o inseriti con successo per il track ID: \(trackId)")
        } catch {
            print("Errore durante l'aggiornamento dei dati del track: \(error)")
        }
    }

}

