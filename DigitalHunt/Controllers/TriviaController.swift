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
    let timeManager = TimeManager.shared
    let statusManager = StatusManager.shared
    var currentQuestionIndex :Int = -1
    var triviaQuestions: [TriviaQuestion]?
    var currentQuestion: TriviaQuestion?
    var allAnswers: [String] = []
    var delay :Int = 0
    var penalty :Int = 1
    
    @IBOutlet weak var qNumber: UILabel!
    @IBOutlet weak var qCategory: UILabel!
    @IBOutlet weak var qText: UITextView!
    @IBOutlet weak var qAns01: UIButton!
    @IBOutlet weak var qAns02: UIButton!
    @IBOutlet weak var qAns03: UIButton!
    @IBOutlet weak var qAns04: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var delayLabel: UILabel!
    
    @IBAction func helpAction(_ sender: Any) {
        helpButton.isEnabled = false
        help()}
    
    override func viewDidLoad() {
        print("sono in TriviaController!")
        setupBackButton()
        super.viewDidLoad()
        self.title = "QUIZ per Tappa \(track.currentNodeIndex+1)"
        fetchTriviaQuestionsFromAPI()
    }
    
    private func fetchTriviaQuestionsFromAPI() {
        triviaAPIManager.fetchTriviaQuestions(isKid: track.isKid) { (fetchedTriviaQuestions, error) in
            if let error = error {
                print("Errore nella richiesta API: \(error)")
                self.triviaAPIManager.loadQuestionsFromJSON(isKid: self.track.isKid) { (questions, error) in
                    if let error = error {
                        print("Errore nel caricamento delle domande dal JSON: \(error)")
                    } else if let questions = questions {
                        // Ora hai le domande dal JSON nell'array 'questions'
                        print("Domande caricate con successo dal JSON: \(questions)")
                        self.triviaQuestions = questions
                        self.populateView()

                        // Esegui le operazioni necessarie con le domande caricate
                    }
                }
                } else if let questions = fetchedTriviaQuestions {
                self.triviaQuestions = questions
                self.populateView()
                /*
                 for question in questions {
                 print("Categoria: \(question.category)")
                 print("Domanda: \(question.question)")
                 print("Risposta corretta: \(question.correct_answer)")
                 }
                 */
            }else {
                print("c'è stato un problema")
                //#TODO: prendi le domande da Json
            }
        }
    }
       
    private func populateView() {
        DispatchQueue.main.async { [self] in // per risolvere errore "Main Thread Checker": si tente di modificare l'interfaccia utente (nello specifico, stai cercando di impostare il testo di una UILabel) da un thread diverso dal thread principale. Tutto ciò che riguarda l'interfaccia utente deve essere eseguito sul thread principale in iOS.
            // Controlla se ci sono domande disponibili prima di incrementare l'indice
            if currentQuestionIndex + 1 < triviaQuestions?.count ?? 0 {
                nextQuestion()
            } else if currentQuestionIndex == ((triviaQuestions?.count ?? 0) - 1) {
                stopQuestion()
               
            } else {
                print("C'è un problema")
            }
        }
    }
    
    private func nextQuestion() {
        
        currentQuestionIndex += 1
        
        if let nextQ = self.triviaQuestions?[self.currentQuestionIndex] {
            self.currentQuestion = nextQ
        } else {
            print("Errore nell'accesso alla prossima domanda")
        }
        self.qNumber.text = "Domanda \(self.currentQuestionIndex + 1) di \(triviaQuestions!.count)"
        self.qCategory.text = decode(from: currentQuestion!.category)
        self.qText.text = decode(from: currentQuestion!.question)
        self.infoLabel.text = ""
        populateButtons()
    }
    
    private func stopQuestion() {
        print("Tutte le domande sono state mostrate")
        setupButton(enable: false)
        infoLabel.text = "Attendi fino al termine della penalità"
        timeManager.startCountDown(duration: delay)
        timeManager.updateHandlerCD = { [weak self] countDownDuration in
            self?.delayLabel.text = "\(countDownDuration) sec."
            
            if countDownDuration == 0 {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func populateButtons() {
        
        setupButton(enable: true)
        
        allAnswers = currentQuestion!.incorrect_answers
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
    }
    
    @objc func handleAnswer(sender: UIButton) {
        // Questa azione verrà chiamata quando uno dei bottoni viene premuto
        let selectedAnswer = sender.titleLabel?.text
        if selectedAnswer == currentQuestion?.correct_answer {
            correctAnswer()
        } else {
            wrongAnswer(sender: sender)
        }
    }
    
    private func correctAnswer(){
        print("Risposta GIUSTA!")
        //navigationController?.popViewController(animated: true)
        populateView()
    }
    
    private func wrongAnswer(sender: UIButton){
        print("peccato! Sei un asino")
        //sender.backgroundColor = UIColor.red
        sender.isEnabled = false
        delay += penalty
        delayLabel.text = "Ritardo accumulato: \(delay)sec."
    }
    
    
    private func decode(from :String) -> String {
        if let decodedData = from.data(using: .utf8) {
            if let attributedString = try? NSAttributedString(data: decodedData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                return attributedString.string
            }
            
        }
        
        return from
    }
    
    private func setupButton(enable: Bool) {
        qAns01.isEnabled = enable
        qAns02.isEnabled = enable
        qAns03.isEnabled = enable
        qAns04.isEnabled = enable
    }
    

    
    func disableButtonAtIndex(_ index: Int) {  //è obbligatorio il _?
        switch index {
        case 0:
            qAns01.isEnabled = false
        case 1:
            qAns02.isEnabled = false
        case 2:
            qAns03.isEnabled = false
        case 3:
            qAns04.isEnabled = false
        default:
            break
        }
    }
    
    func help() {
        let correctAnswerIndex = allAnswers.firstIndex(of: currentQuestion!.correct_answer)
        
        var disabledButtons = Set<Int>()
        
        while disabledButtons.count < 2 {
            let randomIndex = Int.random(in: 0..<4)
            if randomIndex != correctAnswerIndex {
                disabledButtons.insert(randomIndex)
            }
        }
        
        // Ora hai due indici casuali da disabilitare
        for index in disabledButtons {
            disableButtonAtIndex(index)
        }
    }
    
    func setupBackButton(){
        let newBackButton = UIBarButtonItem(title: "Annulla", style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = newBackButton

    }

    @objc func back(_ sender: UIBarButtonItem?) {
        navigationItem.hidesBackButton = true
        let ac = UIAlertController(title: "Questa azione ti farà uscire dall'applicazione", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Si", style: .destructive, handler: { action in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        })
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        ac.addAction(yes)
        ac.addAction(no)
        self.present(ac, animated: true, completion: nil)
    }
    
    
}
