//
//  Util.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/30.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

let appUrl = URL.init(string: "https://apps.apple.com/cn/app/id1516728253")!

enum StoreType:String{
    case state = "state"
    case config = "config"
    case theme = "theme"
    
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
        catch{
            print(error)
        }
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

extension UIColor {
    var image :UIImage {
        let size = CGSize.init(width: 1, height: 1)
        let rect = CGRect.init(origin: .zero, size: size)
        UIGraphicsBeginImageContext( size )
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage ()
        }
        context.addRect(rect)
        context.setFillColor(self.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext()else{
            return UIImage()
        }
        return image
    }
}


extension UIImage{
    
    static func image(color:UIColor) -> UIImage {
        let rect = CGRect.init(origin: CGPoint.zero, size: .init(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.addRect(rect)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
