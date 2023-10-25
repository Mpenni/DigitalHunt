//
//  TimeManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 22/10/23.
//

import Foundation

class TimeManager {
    
    static let shared = TimeManager()
    
    var timer:Timer = Timer()
    var count:Int = 0
    var timerCounting = false  //mi serve?
    var updateHandler: ((String) -> Void)?
    var updateHandlerCD: ((Int) -> Void)?
    var countDownDuration:Int = 0
    let statusManager = StatusManager.shared
        
    private init() {
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
    }
    
    @objc func timerCounter()
    {
        if let startTimeString = statusManager.getStatusPropString(key: "startTime"), let startTime = getDateFromString(startTimeString) {
            let currentTime = Date()
            let timeDifference = currentTime.timeIntervalSince(startTime)
            count = Int(timeDifference)
        } else {
            // Errore nel recupero del tempo di inizio o trasformazione in data
            count = 0
        }

        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        updateHandler?(timeString)
    }

    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", hours) // %=formato 0=riempitivo 2=dimensione d=intero
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    

    func getDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
    
    func startCountDown(duration: Int) {
        // Imposta il timer con l'intervallo specificato (ad esempio, 60 secondi)
        self.countDownDuration = duration
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountDown), userInfo: nil, repeats: true)
    }

    @objc func timerCountDown() {
        // Riduci il valore di duration di 1 secondo
        countDownDuration -= 1
        
        // Verifica se la durata è arrivata a zero
        if countDownDuration < 0 {
            // Ferma il timer
            timer.invalidate()
            // Notifica che il conto alla rovescia è terminato
        } else {
            // Aggiorna il gestore per visualizzare il nuovo valore del conto alla rovescia
            updateHandlerCD?(countDownDuration)
        }
    }
    
    
}
