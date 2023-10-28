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
    
    private let statusLog: Bool = true
    
    
    private init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func setStatusPropString(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
        if statusLog {print("Set STATUS \(key): \(value)")}
    }

    func setStatusPropInt(key: String, value: Int) {
        UserDefaults.standard.set(value, forKey: key)
        if statusLog {print("Set STATUS \(key): \(value)")}

    }

    func getStatusPropString(key: String) -> String? {
        let value = UserDefaults.standard.string(forKey: key)
        if statusLog {print("Get STATUS \(key): \(String(describing: value))")}
        return value
    }

    func getStatusPropInt(key: String) -> Int? {
        let value = UserDefaults.standard.integer(forKey: key)
        if statusLog {print("Get STATUS\(key): \(value)")}
        return value
    }
    
    func resetStatus() {
        if statusLog {print("Reset STATUS")}
        for k in ["currentTrackId", "currentNodeIndex", "startTime"] {
        UserDefaults.standard.set(nil, forKey: k)
        }
    }
    
    func setStartTimeNow() {
        let currentDateTime = Date()
        let formattedDate = dateFormatter.string(from: currentDateTime)
        setStatusPropString(key: "startTime", value: formattedDate)
    }
    
    func printAll() {
        for k in ["currentTrackId", "currentNodeIndex", "startTime"] {
            if let value = getStatusPropString(key: k) {
                print("\(k): \(value)")
            } else if let value = getStatusPropInt(key: k) {
                print("\(k): \(value)")
            } else {
                print("\(k): not set")
            }
        }
    }
}
