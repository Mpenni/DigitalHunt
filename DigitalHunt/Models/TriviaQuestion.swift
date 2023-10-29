//
//  TriviaQuestion.swift
//  DigitalHunt
//
//  Created by Dave Stops on 23/10/23.
//

import Foundation

struct TriviaQuestion: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
       
}
