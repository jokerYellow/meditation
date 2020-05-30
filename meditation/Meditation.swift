//
//  Meditation.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/27.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import UIKit
import UserNotifications
 
private enum notificationId : String{
    case workDone = "com.pipasese.meditation.workDone"
    case breakOver = "com.pipasese.meditation.breakOver"
}

extension Int {
    var duration: String{
        if self/60 > 0 {
            return "\(self/60)分钟"
        }
        return "\(self)秒钟"
    }
}

class Meditation : NSObject{

    enum State :Codable {
        
        enum CodingKeys:CodingKey {
            case wait
            case isBreak
            case isWorking
            case times
            case time
            case startDate
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.isBreak){
                self = .isBreak(times: try container.decode(Int.self, forKey: .times), time: try container.decode(Int.self, forKey: .time), startDate: try container.decode(Date.self, forKey: .startDate))
            }else if container.contains(.isWorking){
                 self = .isWorking(times: try container.decode(Int.self, forKey: .times), time: try container.decode(Int.self, forKey: .time), startDate: try container.decode(Date.self, forKey: .startDate))
            }else{
                self = .wait(times: (try? container.decode(Int.self, forKey: .times)) ?? 0 )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .wait(let times ):
                try container.encode(times, forKey: .times)
                try container.encode(true, forKey: .wait)
            case .isBreak(let times, let time, let startDate):
                try container.encode(times, forKey: .times)
                try container.encode(time, forKey: .time)
                try container.encode(startDate, forKey: .startDate)
                try container.encode(true, forKey: .isBreak)
            case .isWorking(let times, let time, let startDate):
                try container.encode(times, forKey: .times)
                try container.encode(time, forKey: .time)
                try container.encode(startDate, forKey: .startDate)
                try container.encode(true, forKey: .isWorking)
            }
        }
        
        
        case wait(times: Int)
        case isBreak(times: Int, time: Int, startDate: Date)
        case isWorking(times: Int, time: Int, startDate: Date)

        var times: Int {
            switch self {
            case .wait(let times):
                return times
            case .isBreak(let times, _, _), .isWorking(let times, _, _):
                return times;
            }
        }

        var title: String {
            switch self {
            case .wait:
                return "开始"
            case .isBreak:
                return "停止休息"
            case .isWorking:
                return "放弃"
            }
        }

        var lastTime: String {
            switch self {
            case .isWorking(_, let time, let startDate), .isBreak(_, let time, let startDate):
                let duration = Int(Date().timeIntervalSince(startDate))
                let last = Int(time - duration)
                if last <= 0 {
                    return "00:00"
                }
                return String.init(format: "%02d:%02d", last / 60, last % 60)
            default:
                return "开始吧！"
            }
        }
    }

    struct Config {
        //seconds
        var workTime: Int = 10
        var breakTime: Int = 3
        var longBreakTime: Int = 6
        var workPoint: Int = 2
    }

    static let shared = Meditation()

    var config = Config()

    var state: State{
        didSet {
            switch state {
            case .isWorking, .isBreak:
                self.startTimer()
            case .wait:
                self.stopTimer()
            }
            self.stateCallBack?(self.state)
            Util.saveState(state: state)
        }
    }

    var stateCallBack: ((State) -> Void)? {
        didSet {
            self.stateCallBack?(self.state)
        }
    }

    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    var timer: Timer?

    override init() {
        self.state = Util.readState() ?? .wait(times: 0)
        super.init()
        self.startTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(selfCheck), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func selfCheck() -> Void {
        switch self.state {
        case .wait:
            break
        case .isBreak(let times, let time, let startDate):
            if startDate.addingTimeInterval(TimeInterval(time)).compare(Date()) == .orderedAscending {
                self.state = .wait(times: times)
            }
        case .isWorking(_, let time, let startDate):
            if startDate.addingTimeInterval(TimeInterval(time)).compare(Date()) == .orderedAscending {
                self.haveAbreak()
            }
            break
        }
    }

    func start() {
        self.state = .isWorking(times: self.state.times+1, time: self.config.workTime, startDate: Date())
        self.sendNotification(notification: "完成一个番茄钟，休息一下吧", interval: TimeInterval(self.config.workTime), id: .workDone)
    }
    
    func cancelBreak() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId.breakOver.rawValue])
    }
    
    func startTimer() {
        let timer = Timer.init(timeInterval: 1, repeats: true) { (_) in
            self.selfCheck()
            self.stateCallBack?(self.state)
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    func haveAbreak() {
        let time = self.state.times >= self.config.workPoint ? self.config.longBreakTime : self.config.breakTime
        self.state = .isBreak(times: self.state.times, time: time, startDate: Date())
        self.sendNotification(notification: "已经休息\(time.duration)了，开始下一个番茄吧", interval: TimeInterval(time), id : .breakOver)
    }

    func quit() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId.workDone.rawValue])
        self.state = .wait(times: self.state.times)
    }

    private func sendNotification(notification: String, interval: TimeInterval,id: notificationId) {
        var options = UNAuthorizationOptions.init(arrayLiteral: .alert, .sound)
        if #available(iOS 13.0, *) {
            options.insert(.announcement)
        }
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (flag, error) in
            guard flag else {
                return
            }
            let content = UNMutableNotificationContent.init()
            content.body = notification
            content.sound = .default
            let request = UNNotificationRequest.init(identifier: id.rawValue, content: content, trigger:
            UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false))
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (_) in
            })
        }
    }
}

extension Meditation : UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.init(arrayLiteral: .alert,.sound))
    }
    
}
