//
//  ThemeManager.swift
//  meditation
//
//  Created by HuangYaqing on 2020/6/13.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

class ThemeManager {
    
    enum Theme :Int,Decodable,Encodable{
        case dark = 0
        case light = 1
        case system = 2
        var description:String {
            switch self {
            case .dark:
                return NSLocalizedString("Dark", comment: "")
            case .light:
                return NSLocalizedString("Light", comment: "")
            case .system:
                return NSLocalizedString("System", comment: "")
            }
        }
        
        var userInterfaceStyle: UIUserInterfaceStyle{
            switch self {
            case .dark:
                return .dark
            case .light:
                return .light
            case .system:
                return .unspecified
            }
        }
        
        init(userInterfaceStyle:UIUserInterfaceStyle) {
            switch userInterfaceStyle {
            case .dark:
                self = .dark
            case .light:
                self = .light
            default:
                self = .system
            }
        }
        
    }
    
    static let shared = ThemeManager()
    
    var theme : Theme{
        didSet{
            Util.saveInfo(info: theme, t: .theme)
            refreshTheme()
        }
    }
    
    init() {
        self.theme = Util.readInfo(tp: .theme) ?? Theme.system
        refreshTheme()
    }
    
    func refreshTheme(){
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = self.theme.userInterfaceStyle
        } else {
            // Fallback on earlier versions
        }
    }
}
