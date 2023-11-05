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
    
    private let showLog: Bool = true

    private init() {} // Per assicurarci di avere una singola istanza condivisa


    func fetchTriviaQuestions(isKid: Bool, completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        if showLog { print("TriviaAPIMan - 'fetchTriviaQuestions'")}


        var apiUrl = "https://opentdb.com/api.php?amount="
        
        if let questionNumber = configManager.getValue(forKey: "trivia.questionNumber") as? Int {
            if showLog { print("TriviaAPIMan - trivia.questionNumber Value: \(questionNumber)")}
            apiUrl += String(questionNumber)
            } else {
                if showLog { print("TriviaAPIMan - non riesco a recuperare numero domande, setto default")}
            apiUrl += "3" //uso un valore di default nel caso mancasse la configurazione
        }
                    
        if isKid {
            if showLog { print("TriviaAPIMan - is kid")}
            apiUrl += "&difficulty=easy&type=multiple"
        } else {
            if showLog { print("TriviaAPIMan - is NOT kid")}
            apiUrl += "&difficulty=medium&type=multiple"
        }
            
        if showLog { print("TriviaAPIMan - url: \(apiUrl)")}
            
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
                completion(nil, NSError(domain: "No Data Received", code: 0, userInfo: nil))  //#TODO: ????
            }
        }
        task.resume()
    }

    func loadQuestionsFromJSON(isKid: Bool, completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        if showLog { print("TriviaAPIMan - estraggo domande da JSON (loadQuestionsFromJSON)")}

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
