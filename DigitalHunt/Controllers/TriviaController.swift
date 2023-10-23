//
//  QuizController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 23/10/23.
//

import UIKit

class TriviaController: UIViewController {
    
    var track = Track()
    let triviaAPIManager = TriviaAPIManager.shared
    var currentQuestionIndex :Int = -1
    var triviaQuestions: [TriviaQuestion]?
    var currentQuestion: TriviaQuestion?
    var delay :Int = 0
    
    @IBOutlet weak var qNumber: UILabel!
    @IBOutlet weak var qCategory: UILabel!
    @IBOutlet weak var qText: UITextView!
    @IBOutlet weak var qAns01: UIButton!
    @IBOutlet weak var qAns02: UIButton!
    @IBOutlet weak var qAns03: UIButton!
    @IBOutlet weak var qAns04: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    
    @IBAction func helpAction(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QUIZ per Tappa \(track.currentNodeIndex+1)"
        qAns03.setTitle("UFFA!", for: .normal)
        populateTriviaRun()
        // Do any additional setup after loading the view.
    }
    
    private func populateTriviaRun() {
        triviaAPIManager.fetchTriviaQuestions { (fetchedTriviaQuestions, error) in
            if let error = error {
                print("Errore nella richiesta API: \(error)")
                //aggiungere metodo che pesca domande da json
            } else if let questions = fetchedTriviaQuestions {
                self.triviaQuestions = questions
                for question in questions {
                    print("Categoria: \(question.category)")
                    print("Domanda: \(question.question)")
                    print("Risposta corretta: \(question.correct_answer)")
                }
                self.populateView()
                
            }
        }
    }
    
    
    private func populateView() {
        DispatchQueue.main.async { [self] in // per risolvere errore "Main Thread Checker": si tente di modificare l'interfaccia utente (nello specifico, stai cercando di impostare il testo di una UILabel) da un thread diverso dal thread principale. Tutto ciò che riguarda l'interfaccia utente deve essere eseguito sul thread principale in iOS.
            currentQuestionIndex += 1
            //fai metodo next question che verifica se la domanda è lìultima
            self.currentQuestion = self.triviaQuestions?[self.currentQuestionIndex]
            
            print("CurrentQuestionText: \(currentQuestion?.question)")
            self.qNumber.text = "Domanda \(self.currentQuestionIndex + 1) di \(triviaQuestions?.count)"
            self.qCategory.text = decode(from: currentQuestion!.category)
            self.qText.text = decode(from: currentQuestion!.question)
            populateButtons()
            // Gestisci il caso in cui currentQuestion o triviaQuestions siano nil
        }
    }
    
    
    
    private func populateButtons() {
        var allAnswers = currentQuestion!.incorrect_answers
        allAnswers.append(currentQuestion!.correct_answer)
        
        // Mescola l'array in modo casuale
        allAnswers.shuffle()
        
        // Assegna le risposte mescolate ai bottoni
        qAns01.setTitle(decode(from: allAnswers[0]), for: .normal)
        qAns02.setTitle(decode(from: allAnswers[1]), for: .normal)
        qAns03.setTitle(decode(from: allAnswers[2]), for: .normal)
        qAns04.setTitle(decode(from: allAnswers[3]), for: .normal)
        
        // Trova la posizione della risposta corretta dopo la mischiatura
        let correctAnswerIndex = allAnswers.firstIndex(of: currentQuestion!.correct_answer)
        
        // Gestisci le risposte per ciascun bottone
        qAns01.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
        qAns02.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
        qAns03.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
        qAns04.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
        
        // Imposta il tag dei bottoni in base alla posizione della risposta corretta
        qAns01.tag = 0
        qAns02.tag = 1
        qAns03.tag = 2
        qAns04.tag = 3
        
        
    }
    
    @objc func handleAnswer(sender: UIButton) {
        // Questa azione verrà chiamata quando uno dei bottoni viene premuto
        let selectedAnswer = sender.titleLabel?.text
        if selectedAnswer == currentQuestion?.correct_answer {
            print("Risposta GIUSTA!")
            populateView()
            // Gestisci la risposta corretta
        } else {
            print("peccato! Sei un asino")
            // Gestisci una risposta sbagliata
        }
    }
    
    
    private func decode(from :String) -> String {
        if let decodedData = from.data(using: .utf8) {
            if let attributedString = try? NSAttributedString(data: decodedData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                return attributedString.string
            }
            
        }
        
        return from
    }
    
}
