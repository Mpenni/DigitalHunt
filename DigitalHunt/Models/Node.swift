//
//  Node.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//
import Foundation

class Node {
    let id: String
    let name: String
    let lat: Double
    let long: Double
    let desc: String?
    let code: String?

    init(id: String, name: String, lat: Double, long: Double, desc: String?, code: String?) {
        self.id = id
        self.name = name
        self.lat = lat
        self.long = long
        self.desc = desc
        self.code = code
    }
    
    convenience init(id: String, data: [String :Any]) {  //coinvenience: se dentro un costruttore chiamo altro costruttore
        
        let name = data["name"] as? String ?? "noData" //con as? cerca di convertirlo in String, ma è optional, a me non va bene, quindi se non qualcosa va storto scrive "nodata", a
                                                       // altra possibilità fare as! al posto di as?, mi prendo la responsabilità di dichiarare che son sicuro sia String (force casting)
        let lat = data["lat"] as? Double ?? 0.0
        let long = data["long"] as? Double ?? 0.0
        let desc = data["desc"] as? String
        let code = data["code"] as? String
               
        self.init(id: id, name: name, lat: lat, long: long, desc: desc, code: code)
        
    }
    
    
}
