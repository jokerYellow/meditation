//
//  MottoNetwork.swift
//  meditation
//
//  Created by HuangYaqing on 2021/5/25.
//  Copyright © 2021 HuangYaqing. All rights reserved.
//

import Foundation

class MottoNetwork {
    
    
    
    func requestMotto(  callback:@escaping (String)->Void) {
        var called = false
        if let motto :String = Util.readInfo(tp: .motto) {
            callback(motto)
            called = true
        }
        
        let request = URLRequest.init(url: URL.init(string: "https://motto.jollowstudio.com/motto/today")!)
        URLSession.shared.dataTask(with: request ) { (data, response, _) in
            var content = "自强不息"
            if let data = data,let t = String.init(data: data, encoding: .utf8) {
                Util.saveInfo(info: t, t: .motto)
                content = t
            }
            DispatchQueue.main.async {
                if !called {
                    callback(content)
                }
            }
        }.resume()
    }
}
