//
//  TriviaAPIManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 23/10/23.
//

import Foundation

class TriviaAPIManager {
    
    static let shared = TriviaAPIManager()
    let configManager = ConfigManager.shared

    
    private init() {} // Per assicurarci di avere una singola istanza condivisa


    func fetchTriviaQuestions(isKid: Bool, completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        //var apiUrl = "https://opentdb.com/api.php?amount=3&"
        var apiUrl = "https://opentdb.com/api.php?amount="
        
        if let questionNumber = configManager.getValue(forKey: "trivia.questionNumber") as? Int {
            print("TriviaAPIMan - trivia.questionNumber Value: \(questionNumber)")
            apiUrl += String(questionNumber)
            } else {
            print("in TriviaAPI qualcosa non sta funzioanndo")
            apiUrl += "3" //uso un valore di default nel caso mancasse la configurazione
        }
                    
        if isKid {
            apiUrl += "&difficulty=easy&type=multiple"
        } else {
            apiUrl += "&difficulty=medium&type=multiple"
        }
            
        print("apiUrl: \(apiUrl)")
            
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
                        let error = NSError(domain: "Trivia API Error", code: triviaResponse.response_code, userInfo: nil)
                        completion(nil, error)
                    } else {
                        completion(triviaResponse.results, nil)
                    }
                }
                catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, NSError(domain: "No Data Received", code: 0, userInfo: nil))  ///????
            }
        }
        task.resume()
    }

    func loadQuestionsFromJSON(isKid: Bool, completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        // Cerca il file JSON nel bundle dell'app
        print("prendo domande da json")
        let fileName = isKid ? "easyQuestions" : "normalQuestions"
        if let jsonURL = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: jsonURL)
                let questions = try JSONDecoder().decode(TriviaResponse.self, from: jsonData).results
                
                completion(questions, nil)
            } catch {
                completion(nil, error)
            }
        } else {
            let error = NSError(domain: "JSON File Error", code: 0, userInfo: nil)
            completion(nil, error)
        }
    }
}
