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
    var workTime: Int = 10
    var breakTime: Int = 3
    var longBreakTime: Int = 6
    var workPoint: Int = 2
}
