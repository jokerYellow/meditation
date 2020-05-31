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
}
