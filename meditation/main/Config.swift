//
//  Config.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/31.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation

struct Config : Codable,Equatable {
    //seconds
    var workTime: Int = 1500
    var breakTime: Int = 300
    var longBreakTime: Int = 900
    var workPoint: Int = 4
    
}

extension Int {

    ///    seconds to minutes
    var minutes : Int {
        return self/60
    }
    
    ///    minutes to seconds
    var seconds : Int {
           return self*60
    }
}
