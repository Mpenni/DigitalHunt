//
//  StatusManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 21/10/23.
//

import Foundation

class StatusManager {
    
    static let shared = StatusManager()
    
    private let dateFormatter = DateFormatter()
    
    private let showLog: Bool = false
        
    private init() {
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func setStatusProp(key: String, value: String?) {
        UserDefaults.standard.set(value, forKey: key)
        if showLog { print("Set STATUS \(key): \(String(describing: value))") }
    }

    func getStatusProp(key: String) -> String? {
        let value = UserDefaults.standard.string(forKey: key)
        if showLog { print("Get STATUS \(key): \(String(describing: value))") }
        return value
    }
    
    func resetStatus() {
        if showLog { print("Reset STATUS") }
        if showLog { print("STATUS BEFORE reset:") }
        if showLog { printAll() }
        for k in ["currentTrackId", "currentNodeIndex", "startTime"] {
            if showLog { print("Set nil STATUS for \(k)") }
            setStatusProp(key: k, value: nil)
        } 
        if showLog { print("STATUS AFTER reset:") }
        if showLog {printAll()}
    }
    
    func printAll() {
        if showLog { print("printALL in STATUS:") }
        for k in ["currentTrackId", "currentNodeIndex", "startTime", "myFinalTime"] {
            if let value = getStatusProp(key: k) {
                print("    -> \(k): \(value)")
            } else {
                print("    ->  \(k): not set")
            }
        }
    }
    
    func setStartTimeNow() {
        let currentDateTime = Date()
        let formattedDate = dateFormatter.string(from: currentDateTime)
        setStatusProp(key: "startTime", value: formattedDate)
    }
    
    func setMyTotalGameTime () {
        let currentDateTime = Date()

        if let startTimeString = getStatusProp(key: "startTime") {
            if let startTime = getDateFromString(startTimeString) {
                let timeDifference = currentDateTime.timeIntervalSince(startTime)
                // differenza in secondi tra currentDateTime e startTime
                if showLog { print("total time: \(timeDifference)") }
                setStatusProp(key: "myFinalTime", value: String(Int(round(timeDifference)))) //da 27,0 a 27
            } else {
                // Se non è possibile convertire la data di inizio
                setStatusProp(key: "myFinalTime", value: nil)
            }
        } else {
            // Se "startTime" non è presente
            setStatusProp(key: "myFinalTime", value: nil)
        }
    }
    
    func getUserUniqueId() -> String {
        if let currentUniqueId = getStatusProp(key: "UserUniqueId") {
            print("UserUniqueId presente in stato")
            return currentUniqueId
        } else {
            let newUniqueId = generateUniqueAlphanumericCode()
            print("UserUniqueId non presente, generato e salvato nuovo: \(newUniqueId)")
            setStatusProp(key: "UserUniqueId", value: newUniqueId)
            return newUniqueId
        }
    }
    
    func deleteUserUniqueId() { //solo per scopi di test e debug
        setStatusProp(key: "UserUniqueId", value: nil)
    }
        
    private func generateUniqueAlphanumericCode() -> String {
        let uuid = UUID()
        let uuidString = uuid.uuidString
        // per codice più pulito, standardizzato e caseSensitive -> Rimuovo trattini e converto in maiuscolo
        let alphanumericCode = uuidString.replacingOccurrences(of: "-", with: "").uppercased()
        return alphanumericCode
    }
    
    func getDateFromString(_ dateString: String?) -> Date? {
        if dateString == nil {return nil}
        return dateFormatter.date(from: dateString!)
    }
        
}
