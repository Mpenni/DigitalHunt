//
//  EndPageController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 29/10/23.
//


import UIKit

class EndPageController: UIViewController, UITextFieldDelegate {

    var track = Track()
    let timeManager = TimeManager.shared
    let statusManager = StatusManager.shared
    let trackAPIManager = TrackAPIManager.shared
    
    var userTime: Int = 99999999
    var recordTime: Int = 0
    var userIsRecordman :Bool = false
    var userHasRecordTime :Bool = false
    
    private let showLog: Bool = true

    
    //#TODO: aggiungere BOTTONE per tornare ad indexTracks!!!
 
    @IBOutlet weak var userTimeLabel: UILabel!
    
    @IBOutlet weak var recordTimeLabel: UILabel!
      
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        self.title = "Hai concluso il percorso!"
        
        getMyTime()
        getRecordTime()
        userHasRecordTime = getRecordUserAndCompare()
        statusManager.resetStatus()
    }

    private func getRecordUserAndCompare() -> Bool{
        if recordTime > userTime {
            if showLog { print("EndVC - 'recordTime': \(recordTime)")}
            if showLog { print("EndVC - 'userTime': \(userTime)")}
            if showLog { print("EndVC - hai tu il miglior tempo!")}
            updateRecordData()
            if let recordUserIdInTrack = track.recordUserId {
                if statusManager.getUserUniqueId() == recordUserIdInTrack {
                    if showLog { print("EndVC - 'recordID': \(recordUserIdInTrack)")}
                    if showLog { print("EndVC - 'userID': \(statusManager.getUserUniqueId())")}
                    if showLog { print("EndVC - Hai migliorato il tuo stesso record")}
                    resultLabel.text = "Hai migliorato il tuo stesso record"
                    return true
                } else {
                    resultLabel.text = "Hai stabilito il nuovo record!"
                    if showLog { print("EndVC - Hai stabilito il nuovo record! (exRecordID not NIL)")}
                    return true
                }
            } else {
                resultLabel.text = "Hai stabilito il nuovo record!"
                if showLog { print("EndVC - Hai stabilito il nuovo record! (exRecordID NIL)")}
                return true
            }
        } else {
            resultLabel.text = "Non hai stabilito il nuovo record!"
            if showLog { print("EndVC - Non hai stabilito il nuovo record!")}
            return false
        }
    }

    private func getMyTime() {
        if let myFinalTime = statusManager.getStatusProp(key: "myFinalTime"), let myFinalTimeInt = Int(myFinalTime) {
            if showLog { print("EndVC - myfinalTime: \(myFinalTime)")}
            let time = timeManager.secondsToHoursMinutesSeconds(seconds: myFinalTimeInt)
            let timeString = timeManager.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
            userTimeLabel.text = timeString
            if showLog { print("EndVC - timeString: \(timeString)")}
            userTime = myFinalTimeInt
        } else {
            // "myFinalTime" non è presente o non può essere convertito in Int
            userTimeLabel.text = "-nd-"
        }
    }
    
    private func getRecordTime() {
        if let recordTimeInTrack = track.recordUserTime {
            let time = timeManager.secondsToHoursMinutesSeconds(seconds: recordTimeInTrack)
            let timeString = timeManager.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
            print("timeRecord: \(recordTimeInTrack)")
            recordTimeLabel.text = timeString
            recordTime = recordTimeInTrack
        } else {
            // "recordTimeInTrack" non è presente o non può essere convertito in Int
            recordTimeLabel.text = "-nd-"
        }
    }
    
    private func updateRecordData() {
        let myUserId = statusManager.getUserUniqueId()
        // Chiamata asincrona
            Task {
                do {
                    try await trackAPIManager.updateTrackRecordData(trackId: track.id, recordUserId: myUserId, recordUserTime: userTime)
                    if showLog { print("EndVC - update recordData")}
                    if showLog { print("      -> trackId: \(track.id)")}
                    if showLog { print("      -> recordUserId: \(myUserId)")}
                    if showLog { print("      -> userTime: \(userTime)")}
                } catch {
                    print("Errore durante l'aggiornamento del track: \(error)")
                }
            }
    }

    //#TODO: NON è meglio disinibile il pulsante semplicemente?
    
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

