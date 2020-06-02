//
//  BreakingState.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/31.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation

class BreakingState : StateMachine {
    
    weak var delegate: StateMachineDelegate?
    
    var state: Meditation.State
    
    required init(state: Meditation.State,delegate:StateMachineDelegate?) {
        self.state = state
        self.delegate = delegate
    }
    
    //停止休息，开始工作
    func trigger() -> Meditation.State {
        Notification.shared.cancel(type: .breakOver)
        self.beginWork(workTime: self.delegate!.config.workTime, breakTime: self.nextBreakTime)
        print("begin work，times:\(self.state.times + 1),time:\(self.delegate!.config.workTime)")
        return .isWorking(times: self.state.times+1, time: self.delegate!.config.workTime, startDate: Date())
    }
    
    func selfCheck() -> Meditation.State? {
        guard case .isBreak(let times, _, _)  = self.state else {
            return nil
        }
        if self.state.isOver{
            return .wait(times: times)
        }
        return nil
    }
}
