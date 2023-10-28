//
//  QuizController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 23/10/23.
//

import UIKit

class QRCodeController: UIViewController, UITextFieldDelegate {
    
    var track = Track()
 
    @IBOutlet weak var inputCode: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBAction func deleteCodeField(_ sender: Any) {
        inputCode.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputCode.delegate = self
        setupBackButton()
        self.title = "QRCode per tappa \(track.currentNodeIndex + 1)"

        
        infoLabel.text = "Inserisci o inquadra codice di sblocco"
    }
    
    private func checkCode(insertedCode: String) {
        //print("par \(insertedCode)")
        //print("NodeId \(track.getCurrentNode()?.id)")
        //print("codiceGiusto \(track.getCurrentNode()?.code)")
        if insertedCode == track.getCurrentNode()?.code {
            infoLabel.text = "Codice corretto"
            print("Codice corretto")
            self.navigationController?.popViewController(animated: true)
        }

    
        
        /* if insertedCode == track.getCurrentNode?().code {
            print("OK")
        }*/
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

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Testo prima della modifica
        let previousText = textField.text ?? ""
        
        // Calcola il nuovo testo dopo la modifica
        let newText = (previousText as NSString).replacingCharacters(in: range, with: string)
        
        // Esegui il tuo controllo o azione in base al testo inserito
        if newText.isEmpty {
            // Nessun testo inserito
            // Esegui il tuo controllo o azione qui
        } else {
            // Del testo è stato inserito o modificato
            // Esegui il tuo controllo o azione qui
            checkCode(insertedCode: newText)
        }
        
        return true // Ritorna true per consentire la modifica del testo, false per impedirla
    }


    
}

