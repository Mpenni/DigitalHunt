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
        for k in ["currentTrackId", "currentNodeIndex", "startTime"] {
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
}


/*
 class StatusManager {
 
 static let shared = StatusManager()
 
 private let dateFormatter = DateFormatter()
 
 private let showLog: Bool = true
 
 
 private init() {
 dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
 }
 
 func setStatusPropString(key: String, value: String) {
 UserDefaults.standard.set(value, forKey: key)
 if showLog {print("Set STATUS Int \(key): \(value)")}
 }
 
 func setStatusPropInt(key: String, value: Int) {
 UserDefaults.standard.set(value, forKey: key)
 if showLog {print("Set STATUS String \(key): \(value)")}
 
 }
 
 func getStatusPropString(key: String) -> String? {
 let value = UserDefaults.standard.string(forKey: key)
 if showLog {print("Get STATUS String \(key): \(String(describing: value))")}
 return value
 }
 
 func getStatusPropInt(key: String) -> Int? {
 let value = UserDefaults.standard.integer(forKey: key)
 if showLog {print("Get STATUS Int \(key): \(value)")}
 return value
 }
 
 func resetStatus() {
 if showLog {print("Reset STATUS")}
 if showLog {print("STATUS BEFORE reset:")}
 if showLog {printAll()}
 for k in ["currentTrackId", "currentNodeIndex", "startTime"] {
 if showLog {print("Set nil STATUS for \(k)")}
 UserDefaults.standard.set(nil, forKey: k)
 if showLog {printAll()}
 }
 
 }
 
 func setStartTimeNow() {
 let currentDateTime = Date()
 let formattedDate = dateFormatter.string(from: currentDateTime)
 setStatusPropString(key: "startTime", value: formattedDate)
 }
 
 func printAll() {
 if showLog {print("printALL in STATUS:")}
 for k in ["currentTrackId", "currentNodeIndex", "startTime"] {
 if let value = getStatusPropString(key: k) {
 print("    S-> \(k): \(value)")
 } else if let value = getStatusPropInt(key: k) {
 print("    I-> \(k): \(value)")
 } else {
 print("    NS->  \(k): not set")
 }
 }
 }
 }
 */
