//
//  SwitchCell.swift
//  meditation
//
//  Created by HuangYaqing on 2021/5/23.
//  Copyright © 2021 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

class SwitchCell: UITableViewCell {
    
    let switchView = UISwitch()
    
    var valueChange: ((Bool)->Void)?
    
    var value:Bool{
        set{
            self.switchView.isOn = newValue
        }
        get{
            return self.switchView.isOn
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(switchView)
        self.detailTextLabel!.text = " "
        switchView.snp.makeConstraints { (make) in
            make.right.equalTo(self.detailTextLabel!)
            make.centerY.equalTo(self.contentView)
        }
        switchView.addTarget(self, action: #selector(switchValueChange), for: .valueChanged)
    }
    
    @objc func switchValueChange() {
        self.valueChange?(self.value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
