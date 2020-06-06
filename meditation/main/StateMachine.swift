//
//  StateMachine.swift
//  meditation
//
//  Created by HuangYaqing on 2020/6/1.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation

func MapMachine(state:Meditation.State,delegate:StateMachineDelegate) -> StateMachine {
    switch state {
    case .isBreak:
        return BreakingState.init(state: state,delegate: delegate)
    case .isWorking:
        return WorkingState.init(state: state,delegate: delegate)
    case .wait:
        return WaitingState.init(state: state,delegate: delegate)
    }
}

protocol StateMachineDelegate : NSObject {
    var config:Config { get }
}

protocol StateMachine {
    
    var delegate : StateMachineDelegate? { get set }
    
    var state : Meditation.State {get set}
    
    init(state:Meditation.State,delegate:StateMachineDelegate?)
    
    func trigger()->Meditation.State
    
    func selfCheck()->Meditation.State?
}

extension StateMachine{
    
    var nextBreakTime : Int {
        let isLongBreak = (self.state.times+1) >= self.delegate!.config.workPoint
        return isLongBreak ? self.delegate!.config.longBreakTime : self.delegate!.config.breakTime
    }
    
    func beginWork(workTime:Int,breakTime:Int) {
        Notification.shared.clearNotifications()
        Notification.shared.sendNotification(notification: "完成一个番茄钟，休息一下吧", interval: TimeInterval(workTime), id: .workDone)
        Notification.shared.sendNotification(notification: "已经休息\(breakTime.duration)了，开始下一个番茄吧", interval: TimeInterval(breakTime + workTime), id : .breakOver)
    }
    
}
