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
            self.label.text = m
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
