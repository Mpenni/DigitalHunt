//
//  Track.swift
//  DigitalHunt
//
//  Created by Dave Stops on 18/10/23.
// 

import Foundation

class Track {
    let id: String
    let name: String
    let desc: String
    let nodes: [Node]
    let isKid: Bool
    let isQuiz: Bool
    var currentNodeIndex: Int
    let scheduledStart: Date?
    let scheduledEnd: Date?
    var recordUserId: String?
    var recordUserTime: Int?
    
    init () {
        self.id = ""
        self.name = ""
        self.desc = ""
        self.nodes = []
        self.isKid = false
        self.isQuiz = false
        self.currentNodeIndex = -1
        self.scheduledStart = nil
        self.scheduledEnd = nil
        self.recordUserId = nil
        self.recordUserTime = nil
        
    } //costruttore vuoto che mi serve in trackDetails
    
    init(id: String, name: String, desc: String, nodes: [Node], isKid: Bool, isQuiz: Bool, scheduledStart: Date?, scheduledEnd: Date?, recordUserId: String?, recordUserTime: Int?) {
        self.id = id
        self.name = name
        self.desc = desc
        self.nodes = nodes
        self.isKid = isKid
        self.isQuiz = isQuiz
        self.currentNodeIndex = -1
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.recordUserId = recordUserId
        self.recordUserTime = recordUserTime
    }
    
    func setCurrentNodeIndex(index: Int) {
        currentNodeIndex = index
    }
    
    func getCurrentNode() -> Node {
        if currentNodeIndex >= 0, currentNodeIndex < nodes.count {
            return nodes[currentNodeIndex]
        } else {
            return nodes[0]
        }
    }
    
    func checkIsStartNode() -> Bool {
        return currentNodeIndex == 0
    }
    
    func checkIsEndNode() -> Bool {
        return currentNodeIndex == nodes.count - 1
    }
    
    func changeNode() -> Node {
        currentNodeIndex += 1
        if currentNodeIndex >= 0, currentNodeIndex < nodes.count {
            return nodes[currentNodeIndex]
        } else {
            return nodes[0]
        }
    }
    
    func setMyRecord(recordUserId: String, recordUserTime: Int){
        self.recordUserId = recordUserId
        self.recordUserTime = recordUserTime
    }
    
    func initializeTrack() {
        currentNodeIndex = -1
    }
    
    
}
