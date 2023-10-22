//
//  Track.swift
//  DigitalHunt
//
//  Created by Dave Stops on 18/10/23.
// rAVbYNK89hAHJT41dNik LAdg2gqlbVV36fuP8EW2 oco5kKupFumeY9tpo6Uy

import Foundation

class Track {
    let id: String
    let name: String
    let desc: String
    let Nodes: [Node]
    let isKid: Bool
    let isQuiz: Bool
    let currentNodeIndex: Int
    let scheduledStart: Date?
    let scheduledEnd: Date?
    
    init () {
        self.id = ""
        self.name = ""
        self.desc = ""
        self.Nodes = []
        self.isKid = false
        self.isQuiz = false
        self.currentNodeIndex = 0
        self.scheduledStart = nil
        self.scheduledEnd = nil
        
    } //costruttore vuoto che mi serve in trackDetails
    
    init(id: String, name: String, desc: String, nodes: [Node], isKid: Bool, isQuiz: Bool, scheduledStart: Date?, scheduledEnd: Date?) {
        self.id = id
        self.name = name
        self.desc = desc
        self.Nodes = nodes
        self.isKid = isKid
        self.isQuiz = isQuiz
        self.currentNodeIndex = 0
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        
    }
    
}
