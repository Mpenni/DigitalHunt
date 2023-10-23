//
//  TriviaResponse.swift
//  DigitalHunt
//
//  Created by Dave Stops on 16/10/23.
//

import Foundation

struct TriviaResponse: Codable {
    let response_code: Int
    let results: [TriviaQuestion]
}
