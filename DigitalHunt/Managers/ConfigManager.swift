//
//  ConfigManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 29/10/23.
//

import Foundation

class ConfigManager {
    
    static let shared = ConfigManager()
    
    private let showLog: Bool = true

    private init() {
        loadConfig()
    }

    private var config: [String: Any]?

    private func loadConfig() {
        if showLog { print("ConfigMan - 'loadConfig()'") }
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path) {
            do {
                config = try PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]
                if showLog { print("ConfigMan - Config caricato con successo!") }
            } catch {
                print("ERROR: ConfigMan - Errore durante il caricamento del file plist: \(error)")
            }
        } else {
            print("ERROR: ConfigMan - Errore generico")
        }
        printConfig()
    }

    func getValue(forKey key: String) -> Any? {
        return config?[key]
    }
    
    func printConfig() {
        if let config = config {
            for (key, value) in config {
                if showLog { print("ConfigMan - Chiave: \(key), Valore: \(value)") }
            }
        } else {
            if showLog { print("ConfigMan - Config è nullo") }
        }
    }
}
