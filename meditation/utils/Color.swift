//
//  Color.swift
//  meditation
//
//  Created by HuangYaqing on 2020/6/6.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

class Color {
    static var label : UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        }
        return UIColor.black
    }
    
    static func color(light:UIColor,dark:UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .light ? light : dark
            }
        }
        return light
    }
}
