//
//  ViewController.swift
//  fakeWechat
//
//  Created by HuangYaqing on 2019/8/5.
//  Copyright © 2019 HuangYaqing. All rights reserved.
//

import UIKit
import SnapKit
import Rswift

class ViewController: UIViewController {
    let settingButton = UIButton.init()
    
    let pageView : UIScrollView = {
        let rt = UIScrollView.init(frame: .zero)
        rt.isPagingEnabled = true
        return rt
    }()
    
    let baguaView = BaguaView()
    
    let nihongView = NihongView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.pageView)
        self.pageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        let contentView = UIView()
        self.pageView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.pageView)
        }
        contentView.addSubview(baguaView)
        baguaView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self.pageView)
            make.height.equalTo(self.pageView)
            make.width.equalTo(self.view)
        }
        contentView.addSubview(nihongView)
        nihongView.snp.makeConstraints { (make) in
            make.right.bottom.top.equalTo(contentView)
            make.left.equalTo(baguaView.snp.right)
            make.width.equalTo(self.view)
        }
        
        self.settingButton.setImage(R.image.setting(), for: .normal)
        self.settingButton.addTarget(self, action: #selector(gotoSetting), for: .touchUpInside)
        self.view.addSubview(self.settingButton)
        self.settingButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-10)
            make.size.equalTo(CGSize.init(width: 44, height: 44))
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func gotoSetting() {
        self.present(UINavigationController.init(rootViewController: SettingViewController()), animated: true, completion: nil)
    }
    
    
}
