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
    let idLegs: [String]
    //let legs: [Leg]
    let isKid: Bool
    let isQuiz: Bool
    let scheduledStart: Date?
    let scheduledEnd: Date?

    init(id: String, name: String, idLegs: [String], isKid: Bool, isQuiz: Bool, scheduledStart: Date?, scheduledEnd: Date?) {
        self.id = id
        self.name = name
        self.idLegs = idLegs
        self.isKid = isKid
        self.isQuiz = isQuiz
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
    }
}
