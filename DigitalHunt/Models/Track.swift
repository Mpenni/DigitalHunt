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
    let Nodes: [Node]
    let isKid: Bool
    let isQuiz: Bool
    var currentNodeIndex: Int
    let scheduledStart: Date?
    let scheduledEnd: Date?
    let recordUserId: String?
    let recordUserTime: Int?
    
    init () {
        self.id = ""
        self.name = ""
        self.desc = ""
        self.Nodes = []  // NON VA MINUSCOLO?!?
        self.isKid = false
        self.isQuiz = false
        self.currentNodeIndex = 0
        self.scheduledStart = nil
        self.scheduledEnd = nil
        self.recordUserId = nil
        self.recordUserTime = nil
        
    } //costruttore vuoto che mi serve in trackDetails
    
    init(id: String, name: String, desc: String, nodes: [Node], isKid: Bool, isQuiz: Bool, scheduledStart: Date?, scheduledEnd: Date?, recordUserId: String?, recordUserTime: Int?) {
        self.id = id
        self.name = name
        self.desc = desc
        self.Nodes = nodes
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
        //print("setto index in track da status = \(index)")
    }
    
    func getCurrentNode() -> Node? {
        if currentNodeIndex >= 0, currentNodeIndex < Nodes.count {
            return Nodes[currentNodeIndex]
        } else {
            return nil
        }
    }
    
    func checkIsStartNode() -> Bool {
        return currentNodeIndex == 0
    }
    
    func checkIsEndNode() -> Bool {
        return currentNodeIndex == Nodes.count - 1
    }
    
    func changeNode() -> Node {
        currentNodeIndex += 1
        return Nodes[currentNodeIndex]
    }
    
    
}
