//
//  TriviaAPIManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 23/10/23.
//

import Foundation

class TriviaAPIManager {
    
    static let shared = TriviaAPIManager()
    
    private init() {} // Per assicurarti di avere una singola istanza condivisa

    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        //let apiUrl = "https://opentdb.com/api.php?amount=3&difficulty=easy&type=multiple"
        let apiUrl = "https://opentdb.com/api.php?amount=3&difficulty=easy&type=multiple"

        guard let url = URL(string: apiUrl) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            if let data = data {
                do {
                    let triviaResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                    completion(triviaResponse.results, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, NSError(domain: "No Data Received", code: 0, userInfo: nil))
            }
        }

        task.resume()
    }
}
