//
//  ConfigManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 29/10/23.
//

import Foundation

class ConfigManager {
    static let shared = ConfigManager()

    private init() {
        loadConfig()
    }

    private var config: [String: Any]?

    private func loadConfig() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path) {
            do {
                config = try PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]
                print("Config caricato con successo!")
            } catch {
                print("Errore durante il caricamento del file plist: \(error)")
            }
        } else {
            print("Qualcosa è andato storto")
        }
        
        printConfig()
        
    }


    func getValue(forKey key: String) -> Any? {
        return config?[key]
    }
    
    func printConfig() {
        if let config = config {
            for (key, value) in config {
                print("Chiave: \(key), Valore: \(value)")
            }
        } else {
            print("Config è nullo.")
        }
    }

}
