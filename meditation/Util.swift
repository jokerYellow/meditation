//
//  Util.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/30.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation
 
enum StoreType:String{
    case state = "state"
    case config = "config"
    
    static var storedDirectory : URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL.init(fileURLWithPath: "\(path)/stored")
    }
    
    var storedUrl : URL {
        var d = StoreType.storedDirectory
        if !FileManager.default.fileExists(atPath: d.absoluteString) {
            try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true, attributes: nil)
        }
        d.appendPathComponent(self.rawValue)
        return d
    }
}

class Util {
    
    static func saveInfo<T:Codable>(info:T,t:StoreType){
        do{
            let data = try JSONEncoder().encode(info)
            try data.write(to: t.storedUrl,options: .atomic)
        }
        catch{}
    }
       
    static func readInfo<T:Codable>(tp:StoreType)->T?{
        do{
            let data = try Data.init(contentsOf: tp.storedUrl)
            let info = try JSONDecoder().decode(T.self, from: data)
            return info
        }catch{}
        return nil
   }
    
    
}
