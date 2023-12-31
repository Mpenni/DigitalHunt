//
//  TriviaController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 23/10/23.
//

import UIKit

class TriviaController: UIViewController {
    
    var track = Track()
    let triviaAPIManager = TriviaAPIManager.shared
    let timeManager = TimeManager.shared
    let configManager = ConfigManager.shared

    var currentQuestionIndex :Int = -1
    var triviaQuestions: [TriviaQuestion]?
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
    
    private let showLog: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if showLog { print("TriviaC - Did Load")}
        setupBackButton()
        self.title = "QUIZ per Tappa \(track.currentNodeIndex+1)"
        setConfig()                        //carico configurazione
        fetchTriviaQuestionsFromAPI()      //carico le domande
    }
    
    private func setConfig() {
        if showLog { print("TriviaC - chiamo  'setConfig()', setto durata penalità")}
        if  let confPenalty = configManager.getValue(forKey: "trivia.penalty") as? Int {
            penalty = confPenalty
        }
    }
    
    private func fetchTriviaQuestionsFromAPI() {
        if showLog { print("TriviaC - sono in 'fetchTriviaQuestionsFromAPI()'")}
        triviaAPIManager.fetchTriviaQuestions(isKid: track.isKid) { (fetchedTriviaQuestions, error) in
            if let error = error {
                //c'è un errore nel servizio API, provo ad estrarre domande da file json
                print("ERRORE TriviaC: Errore nella richiesta API: \(error)")
                self.triviaAPIManager.loadQuestionsFromJSON(isKid: self.track.isKid) { (questions, error) in
                    if let error = error {
                        print("ERRORE TriviaC: Errore nel caricamento delle domande dal JSON: \(error)")
                        ErrorManager.showError(view: self, message: "TriviaC: Errore nel caricamento delle domande dal JSON", gotoRoot: true)
                    } else if let questions = questions {
                        // Salvo le domande dal Json API all'array questions
                        if self.showLog { print("TriviaC - Domande caricate con successo dal JSON: \(questions)")}
                        self.triviaQuestions = questions
                        self.populateView()
                    }
                }
                
            } else if let questions = fetchedTriviaQuestions {  // ottengo domande da API e le memorizzo
                self.triviaQuestions = questions
                self.populateView()

            } else {  // fetchedTriviaQuestions + error nulli
                print("ERRORE TriviaC: c'è stato un problema")
                ErrorManager.showError(view: self, message: "Non è possibile recuperae le domande", gotoRoot: true)
            }
        }
    }
       
    private func populateView() {
        if showLog { print("TriviaC - sono in 'populateView()'")}
        DispatchQueue.main.async { [self] in // per risolvere errore "Main Thread Checker": si tenta di modificare l'interfaccia utente da un thread diverso dal thread principale. Tutto ciò che riguarda l'interfaccia utente deve essere eseguito sul thread principale in iOS.
            
            // Controlla se ci sono domande disponibili prima di incrementare l'indice
            if currentQuestionIndex + 1 < triviaQuestions!.count {
                //controllo l'esistenza dell'elemento successivo dell'array
                nextQuestion()
            } else if currentQuestionIndex == triviaQuestions!.count - 1 {
                stopQuestion()
            } else {
                print("ERRORE TriviaC: c'è stato un problema")
                // l'errore è bloccante, torno alla schermata iniziale
                ErrorManager.showError(view: self, message: "C'è stato un problema. Riprova a selezionare il percorso.", gotoRoot: true)
            }
        }
    }
    
    private func nextQuestion() {
        // carico nella view la domanda
        if showLog { print("TriviaC - sono in 'nextQuestion()'")}
        currentQuestionIndex += 1    // incremento l'index della domanda
        if triviaQuestions?[self.currentQuestionIndex] == nil {
            print("ERRORE TriviaC: Errore nell'accesso alla prossima domanda")
            // l'errore è bloccante, torno alla schermata iniziale
            ErrorManager.showError(view: self, message: "C'è stato un problema: riprova a selezionare il percorso", gotoRoot: true)
        }
        self.qNumber.text = "Domanda \(self.currentQuestionIndex + 1) di \(triviaQuestions!.count)"
        self.qCategory.text = decode(from: triviaQuestions![currentQuestionIndex].category)
        self.qText.text = decode(from: triviaQuestions![currentQuestionIndex].question)
        self.infoLabel.text = ""
        populateButtons()
    }
    
    private func stopQuestion() {
        // il set corrente di domande è terminato, sconto eventuale penalità e torno alla view principale
        if showLog { print("TriviaC -  sono in 'stopQuestion()'")}
        if showLog { print("        -> Tutte le domande sono state mostrate")}
        setupButton(enable: false)
        infoLabel.text = "Attendi fino al termine della penalità"
        timeManager.startCountDown(duration: delay)
        timeManager.updateHandlerCD = { [weak self] countDownDuration in
            self?.delayLabel.text = "Ritardo accumulato: \(countDownDuration) sec."
            if countDownDuration == 0 {
                self?.navigationController?.popViewController(animated: true)
            }
        } //update del countdown timer con handler invocato da TimeManager (gli passo una funzione anonima istanziata e chiamata da TimeManager)
    }
    
    private func populateButtons() {
        // Popolo i 4 buttons delle risposte
        if showLog { print("TriviaC -  sono in 'populateButtons()'")}
        setupButton(enable: true)
        allAnswers = triviaQuestions![currentQuestionIndex].incorrect_answers
        allAnswers.append(triviaQuestions![currentQuestionIndex].correct_answer)
         
        // Mischio l'array in modo casuale
        allAnswers.shuffle()
        
        // Assegna le risposte mescolate ai bottoni
        qAns01.setTitle(decode(from: allAnswers[0]), for: .normal)
        qAns02.setTitle(decode(from: allAnswers[1]), for: .normal)
        qAns03.setTitle(decode(from: allAnswers[2]), for: .normal)
        qAns04.setTitle(decode(from: allAnswers[3]), for: .normal)
        
        // Gestisco le risposte per ciascun bottone
        qAns01.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
        qAns02.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
        qAns03.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
        qAns04.addTarget(self, action: #selector(handleAnswer), for: .touchUpInside)
    }
    
    @objc func handleAnswer(sender: UIButton) {
        if showLog { print("TriviaC - 'handleAnswer'")}
        let selectedAnswer = sender.titleLabel?.text
        if selectedAnswer == decode(from: triviaQuestions![currentQuestionIndex].correct_answer) {
            correctAnswer()
        } else {
            wrongAnswer(sender: sender)
        }
    }
    
    private func correctAnswer(){
        if showLog { print("TriviaC - 'correctAnswer()'")}
        populateView()
    }
    
    private func wrongAnswer(sender: UIButton){
        // gestisco la risposta sbagliata, accumulando il ritardo
        if showLog { print("TriviaC - 'wrongAnswer'")}
        sender.isEnabled = false
        delay += penalty
        delayLabel.text = "Ritardo accumulato: \(delay) sec."
        
        if !qAns01.isEnabled && !qAns02.isEnabled && !qAns03.isEnabled && !qAns04.isEnabled {
                // Se tutti i bottoni sono disabilitati, passa oltre
                correctAnswer()
            }
    }
    
    private func decode(from :String) -> String {
        // decodifico il dato da codifica HTML a stringa normale
        if let decodedData = from.data(using: .utf8) {
            if let attributedString = try? NSAttributedString(data: decodedData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                return attributedString.string
            }
        }
        return from
    }
    
    private func setupButton(enable: Bool) {
        if showLog { print("TriviaC - 'setupButton' con enable: \(enable)")}
        qAns01.isEnabled = enable
        qAns02.isEnabled = enable
        qAns03.isEnabled = enable
        qAns04.isEnabled = enable
    }
    
    func disableButtonAtIndex(_ index: Int) { //_ in quanto il parametro è anonimo 
        if showLog { print("TriviaC - 'disableButtonAtIndex': \(index)")}
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
        // Disabilito 2 delle 3 risposte errate
        if showLog { print("TriviaC - 'help()'")}
        let correctAnswerIndex = allAnswers.firstIndex(of: triviaQuestions![currentQuestionIndex].correct_answer)
        
        var disabledButtons = Set<Int>()
        
        // Cerco due risposte errate
        while disabledButtons.count < 2 {
            let randomIndex = Int.random(in: 0..<4)
            if randomIndex != correctAnswerIndex {
                disabledButtons.insert(randomIndex)
            }
        }
        
        // disabilito i bottoni relativi agli indici trovati
        for index in disabledButtons {
            disableButtonAtIndex(index)
        }
    }
    
    func setupBackButton(){
        if showLog { print("TriviaC - 'setupBackButton()'")}
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
