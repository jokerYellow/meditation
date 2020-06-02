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
    
    //停止工作状态
    func trigger() -> Meditation.State {
        Notification.shared.cancel(type: .workDone)
        Notification.shared.cancel(type: .breakOver)
        print("work interupt，times:\(self.state.times)")
        return .wait(times: self.state.times)
    }
    
    func selfCheck() -> Meditation.State? {
        guard case .isWorking(let times, let time, let startDate) = self.state else {
            return nil
        }
        if self.state.isOver{
            return self.haveAbreak(startData: startDate.addingTimeInterval(TimeInterval(time)))
        }
        return nil
    }
    
    func haveAbreak(startData:Date)->Meditation.State {
        let isLongBreak = self.state.times >= self.delegate!.config.workPoint
        let time = isLongBreak ? self.delegate!.config.longBreakTime : self.delegate!.config.breakTime
        print("isLongBreak:\(isLongBreak),break duration:\(time.duration)")
        return .isBreak(times: isLongBreak ? 0 : self.state.times, time: time, startDate: startData)
    }

}
