//
//  WaitingState.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/31.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation


class WaitingState : StateMachine {
    weak var delegate: StateMachineDelegate?
    
    required init(state: Meditation.State,delegate:StateMachineDelegate?) {
          self.state = state
          self.delegate = delegate
      }
    
    var state: Meditation.State
    //开始工作
    func trigger() -> Meditation.State {
        self.beginWork()
        return .isWorking(times: self.state.times+1, time: self.delegate!.config.workTime, startDate: Date())
    }
}
