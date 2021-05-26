//
//  MottoView.swift
//  meditation
//
//  Created by HuangYaqing on 2021/5/25.
//  Copyright © 2021 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

class MottoView: UIView {
    
    let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    let motto = MottoNetwork()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.edges.equalTo(self)
        }
        motto.requestMotto { (m) in
            let att = NSMutableAttributedString.init(string: m)
            let p = NSMutableParagraphStyle.init()
            p.lineSpacing = 10
            let range = NSRange.init(location: 0, length: m.count)
            att.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: range)
            p.alignment = .center
            att.addAttribute(NSAttributedString.Key.paragraphStyle, value: p, range: range)
            self.label.attributedText = att
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
