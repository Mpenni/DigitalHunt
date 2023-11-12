//
//  TimeManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 22/10/23.
//

import Foundation

class TimeManager {
    
    static let shared = TimeManager()
    
    var timer: Timer = Timer()
    var countDowntimer: Timer = Timer()
    var count:Int = 0
    var timerCounting = false  
    var updateHandler: ((String) -> Void)?   // istanzio la funzione che è definita in HuntMapController
    var updateHandlerCD: ((Int) -> Void)?    // istanzio la funzione che è definita in HuntMapController
    var countDownDuration:Int = 0
    let statusManager = StatusManager.shared
    var timerEnabled: Bool = false
    
    private let showLog: Bool = false

        
    private init() {
    }
    
    func startTimer() {
        if showLog {print("TimeM: startTimer")}
        if timerEnabled == false {
            if showLog {print("TimeM: checkStatus")}
            timerEnabled = true
            if let startTimeString = statusManager.getStatusProp(key: "startTime"), let startTime = getDateFromString(startTimeString) {
                let currentTime = Date()
                let timeDifference = currentTime.timeIntervalSince(startTime)
                count = Int(timeDifference)
            } else {
                if showLog {print("TimeM: Status nil, count = 0")}
                count = 0
            }
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)}
        else {
            if showLog {print("TimeM: timer già partito (timerEnabled == true)")}
        }
    }
    
    @objc func timerCounter()
    {
        count += 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        if timerEnabled {
            if showLog {print("TimeM: timeCounter (update timer!)")}
            if showLog {print("TimeM: timeCounter: \(timeString)")}
            updateHandler?(timeString)}  //lancio funzione definita in HuntMap, passandogli nuova stringa
        else {
            timer.invalidate()
            if showLog {print("TimeM: timerCounter (timer NOT updated)")}
            }
    }
    
    func stopTimer() {
        timerEnabled = false
        timer.invalidate()
        if showLog {print("TimeM: stopTimer()")}
    }

    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)  //restituisco una tupla
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
    
    func getDateFromString(_ dateString: String?) -> Date? {
        if dateString == nil {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString!)
    }
    
    func getStringFromDate(_ date: Date?) -> String? {
        if date == nil {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date!)
    }
    
    func startCountDown(duration: Int) {
        // Imposta il timer con l'intervallo specificato (ad esempio, 60 secondi)
        self.countDownDuration = duration + 1
        self.countDowntimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountDown), userInfo: nil, repeats: true)
    }

    @objc func timerCountDown() {
        countDownDuration -= 1
        if showLog {print("TimeM: countDownUpdate")}
        if countDownDuration < 0 {
            countDowntimer.invalidate()
        } else {
            updateHandlerCD?(countDownDuration) //lancio funzione definita in HuntMap, passandogli nuova stringa
        }
    }

}
