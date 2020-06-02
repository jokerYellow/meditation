//
//  Meditation.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/27.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import UIKit
import UserNotifications

extension Int {
    var duration: String{
        if self/60 > 0 {
            return "\(self/60)分钟"
        }
        return "\(self)秒钟"
    }
}

class Meditation : NSObject, StateMachineDelegate{

    enum State :Codable,Equatable {
        
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
                try container.encode(0, forKey: .times)
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
        var time: Int {
            switch self {
            case .wait:
                return 0
            case .isBreak(_, let time, _), .isWorking(_, let time, _):
                return time;
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
        
        var isOver : Bool{
            switch self {
            case .wait:
                return false
            case .isBreak(_, let time, let startDate), .isWorking(_, let time, let startDate):
                return startDate.addingTimeInterval(TimeInterval(time)).compare(Date()) == .orderedAscending
            }
        }
        
    }

    static let shared = Meditation.init(config: Config())

    var config : Config

    var state: State{
        didSet {
            switch state {
            case .isWorking, .isBreak:
                self.startTimer()
            case .wait:
                self.stopTimer()
            }
            self.stateCallBack?(self.state)
            Util.saveInfo(info: self.state, t: .state)
        }
    }
    
    var stateMachine : StateMachine!

    var stateCallBack: ((State) -> Void)? {
        didSet {
            self.stateCallBack?(self.state)
        }
    }
    
    var timer: Timer?

    init(config:Config) {
        self.config = config
        self.state = Util.readInfo(tp: .state) ?? .wait(times: 0)
        super.init()
        self.stateMachine = MapMachine(state: self.state,delegate: self)
        self.startTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(selfCheck), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func selfCheck() -> Void {
        guard let state = self.stateMachine.selfCheck() else{
            return
        }
        self.state = state
        self.stateMachine = MapMachine(state: state, delegate: self)
    }
    
    func trigger() {
        self.state = self.stateMachine.trigger()
        self.stateMachine = MapMachine(state: self.state,delegate: self)
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

}
