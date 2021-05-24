//
//  ScreenManager.swift
//  meditation
//
//  Created by HuangYaqing on 2021/5/24.
//  Copyright © 2021 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

class ScreenManager {
    
    static let shared = ScreenManager()
    
    init() {
        refresh()
    }
    
    func refresh(){
        guard let config :Config = Util.readInfo(tp: .config) else{
            return
        }
        keepOn(on: config.isLongLighting)
    }
    
    func keepOn(on:Bool) {
        UIApplication.shared.isIdleTimerDisabled = on
    }
    
}
