//
//  WorkingState.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/31.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation

class WorkingState : StateMachine {
    weak var delegate: StateMachineDelegate?
    
    required init(state: Meditation.State,delegate:StateMachineDelegate?) {
        self.state = state
        self.delegate = delegate
    }
    
    var state: Meditation.State
    
    func trigger() -> Meditation.State {
        Notification.shared.cancel(type: .workDone)
        return .wait(times: self.state.times)
    }
    
    func selfCheck() -> Meditation.State? {
        guard case .isWorking(let times, let time, let startDate) = self.state else {
            return nil
        }
        if startDate.addingTimeInterval(TimeInterval(time)).compare(Date()) == .orderedAscending {
            return self.haveAbreak()
        }
        return nil
    }
    
    func haveAbreak()->Meditation.State {
        let time = self.state.times >= self.delegate!.config.workPoint ? self.delegate!.config.longBreakTime : self.delegate!.config.breakTime
        Notification.shared.sendNotification(notification: "已经休息\(time.duration)了，开始下一个番茄吧", interval: TimeInterval(time), id : .breakOver)
        return .isBreak(times: self.state.times, time: time, startDate: Date())
    }

}
