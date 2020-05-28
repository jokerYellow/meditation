//
//  Meditation.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/27.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import UIKit
import UserNotifications

private let id = "com.pipasese.meditation"

private extension Int {
    var timeinterval: TimeInterval {
        return TimeInterval(self * 60)
    }
}

class Meditation {

    enum State {
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
                let duration = Date().timeIntervalSince(startDate)
                let last = Int(time.timeinterval - duration)
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
        var workTime: Int = 25
        var breakTime: Int = 5
        var longBreakTime: Int = 15
        var workPoint: Int = 4
    }

    static let shared = Meditation()

    var config = Config()

    var state: State = .wait(times: 0) {
        didSet {
            switch state {
            case .isWorking, .isBreak:
                self.startTimer()
            case .wait:
                self.stopTimer()
            }
            self.stateCallBack?(self.state)
        }
    }

    var stateCallBack: ((State) -> Void)? {
        didSet {
            self.stateCallBack?(self.state)
        }
    }

    var timer: Timer?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(selfCheck), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func selfCheck() -> Void {
        switch self.state {
        case .wait:
            break
        case .isBreak(let times, let time, let startDate):
            if startDate.addingTimeInterval(time.timeinterval).compare(Date()) == .orderedAscending {
                self.state = .wait(times: times)
            }
        case .isWorking(_, let time, let startDate):
            if startDate.addingTimeInterval(time.timeinterval).compare(Date()) == .orderedAscending {
                self.haveAbreak()
            }
            break
        }
    }

    func start() {
        self.state = .isWorking(times: self.state.times, time: self.config.workTime, startDate: Date())
        self.sendNotification(content: "完成一个番茄钟，休息一下吧", interval: self.config.workTime.timeinterval)
    }

    func startTimer() {
        let timer = Timer.init(timeInterval: 1, repeats: true) { (_) in
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
        let time = self.state.times > self.config.workPoint ? self.config.longBreakTime : self.config.breakTime
        self.state = .isBreak(times: self.state.times, time: time, startDate: Date())
        self.sendNotification(content: "已经休息\(time)分钟了，开始下一个番茄吧", interval: time.timeinterval)
    }

    func quit() {
        self.state = .wait(times: self.state.times)
    }

    func sendNotification(notification: String, interval: TimeInterval) {
        var options = UNAuthorizationOptions.init(arrayLiteral: .alert, .sound)
        if #available(iOS 13.0, *) {
            options.insert(.announcement)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (flag, error) in
            guard flag else {
                return
            }
            let content = UNMutableNotificationContent.init()
            content.body = notification
            let request = UNNotificationRequest.init(identifier: id, content: content, trigger:
            UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false))
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (_) in
            })
        }
    }

}
