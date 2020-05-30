//
//  Util.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/30.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation

class Util {
    static var url : URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL.init(fileURLWithPath: "\(path)/state")
    }
    
    static func saveState(state:Meditation.State){
        do{
            let data = try JSONEncoder().encode(state)
            try data.write(to: self.url)
        }
        catch{
            
        }
    }
    
    static func readState()->Meditation.State?{
        do{
            let data = try Data.init(contentsOf: Util.url)
            let state = try JSONDecoder().decode(Meditation.State.self, from: data)
            return state
        }catch{
            return nil
        }
    }
}
