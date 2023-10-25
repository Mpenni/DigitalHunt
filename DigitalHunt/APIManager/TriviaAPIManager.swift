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

    func fetchTriviaQuestions(isKid: Bool, completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        var apiUrl = "https://opentdb.com/api.php?amount=3&"

        if isKid {
            apiUrl += "difficulty=easy&type=multiple"
        } else {
            apiUrl += "difficulty=medium&type=multiple"
        }

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

                    if triviaResponse.response_code != 0 {
                        // Gestisci l'errore in base al response_code
                        let error = NSError(domain: "Trivia API Error", code: triviaResponse.response_code, userInfo: nil)
                        completion(nil, error)
                    } else {
                        completion(triviaResponse.results, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, NSError(domain: "No Data Received", code: 0, userInfo: nil))  ///????
            }
        }

        task.resume()
    }

    /*
    func fetchTriviaQuestions(isKid: Bool, completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        //let apiUrl = "https://opentdb.com/api.php?amount=3&difficulty=easy&type=multiple"
        var apiUrl = "https://opentdb.com/api.php?"

        if isKid {
            apiUrl += "difficulty=easy&type=multiple"
        } else {
            apiUrl += "difficulty=medium&type=multiple"
        }
        
        print("APIurl: \(apiUrl)")
        
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
    } */
}
