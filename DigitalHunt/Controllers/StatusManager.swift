//
//  StatusManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 21/10/23.
//

import Foundation

class StatusManager {
    
    static let shared = StatusManager()
    
    private init() {}
    
    
    func setStatusProp(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getStatusProp(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    
    func printAll() {
        for k in ["currentTrackId", "nextNodeId", "startTime"] {
            print((getStatusProp(key: k) ?? "not set") as String)
        }
    }
    
    
}
