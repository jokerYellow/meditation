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
        let request = URLRequest.init(url: URL.init(string: "https://motto.jollowstudio.com/motto/today")!)
        URLSession.shared.dataTask(with: request ) { (data, response, _) in
            let content :String
            if let data = data,let t = String.init(data: data, encoding: .utf8) {
                content = t
            }else{
                content = "自强不息"
            }
            DispatchQueue.main.async {
                callback(content)
            }
        }.resume()
    }
}
