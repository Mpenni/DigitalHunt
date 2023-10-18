import Foundation
import FirebaseFirestore

class TrackAPIManager {
    static let shared = TrackAPIManager()
    
    private init() {}
    
    var tracks: [Track] = [] // Array per archiviare le tracce
    
    // Funzione asincrona per recuperare tutti i tracks da Firebase
    func getAllTracks() async throws -> [Track] {
        let db = Firestore.firestore()
        
        // Utilizza "await" per aspettare il risultato dell'operazione Firebase
        let querySnapshot = try await db.collection("tracks").getDocuments()
        
        var fetchedTracks: [Track] = [] // Crea un array temporaneo per le tracce
        
        for document in querySnapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String, // Verifica se "name" è una stringa
               let isKid = data["isKid"] as? Bool, // Verifica se "isKid" è un booleano
               let isQuiz = data["isQuiz"] as? Bool { // Verifica se "isQuiz" è un booleano
               
                let id = document.documentID
                let idLegs = data["idLegs"] as? [String] ?? [] // Leggi l'array "idLegs" con un valore predefinito vuoto
                let scheduledStartTimestamp = data["scheduledStart"] as? Timestamp
                let scheduledEndTimestamp = data["scheduledEnd"] as? Timestamp
                let scheduledStart = scheduledStartTimestamp?.dateValue()
                let scheduledEnd = scheduledEndTimestamp?.dateValue()
                
                // Crea un oggetto "Track" utilizzando i dati ottenuti da Firebase
                let track = Track(id: id, name: name, idLegs: idLegs, isKid: isKid, isQuiz: isQuiz, scheduledStart: scheduledStart, scheduledEnd: scheduledEnd)
                fetchedTracks.append(track)
            }
        }
        
        // Aggiorna l'array delle tracce con i dati appena ottenuti
        self.tracks = fetchedTracks
        
        // Restituisci l'array delle tracce
        return fetchedTracks
    }
    
    // Funzione per stampare ciclicamente i dati delle tracce nell'array
    func printTracksData() {
        for track in tracks {
            print("Track ID: \(track.id)")
            print("Name: \(track.name)")
            print("Is Kid: \(track.isKid)")
            print("Is Quiz: \(track.isQuiz)")
            // Aggiungi qui altre proprietà da stampare
        }
    }
}
