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
    
    var userTime: Int = 99999999
    var recordTime: Int = 0
    var userIsRecordman :Bool = false
    var userHasRecordTime :Bool = false
    
    //#TODO: aggiungere BOTTONE per tornare ad indexTracks!!!
 
    @IBOutlet weak var userTimeLabel: UILabel!
    
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        self.title = "Hai concluso il percorso!"
        
        getMyTime()
        getRecordTime()
        userIsRecordman = getRecordUserAndCompare()
        userHasRecordTime = compareResults()

        statusManager.resetStatus()
    }
    
    private func compareResults() -> Bool {
        if recordTime > userTime {
            print("hai tu il miglior tempo!")
            return true
        }
        print("NON hai tu il miglior tempo!")
        return false
    }
    
    private func getRecordUserAndCompare() -> Bool{
        if let recordUserIdInTrack = track.recordUserId {
            if statusManager.getUserUniqueId() == recordUserIdInTrack {
                print("tu sei il recordman!")
                return true
            } else {
                print("tu NON sei il recordman!")
                return false
            }
        }
        return false
    }

    private func getMyTime() {
        if let myFinalTime = statusManager.getStatusProp(key: "myFinalTime"), let myFinalTimeInt = Int(myFinalTime) {
            print("myfinalTime: \(myFinalTime)")
            let time = timeManager.secondsToHoursMinutesSeconds(seconds: myFinalTimeInt)
            let timeString = timeManager.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
            userTimeLabel.text = timeString
            print("timeString: \(timeString)")

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

