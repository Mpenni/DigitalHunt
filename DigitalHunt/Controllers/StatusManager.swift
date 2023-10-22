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
    
    func setStatusProp(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getStatusProp(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    
    func resetStatus() {
        for k in ["currentTrackId", "nextNodeId", "startTime"] {
        UserDefaults.standard.set(nil, forKey: k)
        }
    }
    
    func setStartTimeNow() {
        let currentDateTime = Date()
        let formattedDate = dateFormatter.string(from: currentDateTime)
        setStatusProp(key: "startTime", value: formattedDate)
    }
    
    func printAll() {
        for k in ["currentTrackId", "nextNodeId", "startTime"] {
            if let value = getStatusProp(key: k) {
                print("\(k): \(value)")
            } else {
                print("\(k): not set")
            }
        }
    }
}
