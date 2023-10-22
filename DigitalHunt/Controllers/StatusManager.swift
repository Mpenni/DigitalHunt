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
    
    
    private init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func setStatusPropString(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func setStatusPropInt(key: String, value: Int) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func getStatusPropString(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    func getStatusPropInt(key: String) -> Int? {
        UserDefaults.standard.integer(forKey: key)
    }
    
    func resetStatus() {
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
