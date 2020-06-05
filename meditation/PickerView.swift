//
//  PickerView.swift
//  meditation
//
//  Created by HuangYaqing on 2020/6/3.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

protocol Picker {
    func show(title:String,items:[String],dw:String,defaultIndex:Int,complete:((Int)->Void)?)
}

class PickerView: UIView,Picker,UIPickerViewDataSource,UIPickerViewDelegate {
    var items:[String] = []
    
    lazy var saveButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", for: .normal)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(callBack), for: .touchUpInside)
        return btn
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .white
        }
        return label
    }()
    
    let dwLabel : UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .white
        }
        return label
    }()
    
    var complete: ((Int)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.picker)
        self.addSubview(self.saveButton)
        self.addSubview(self.titleLabel)
        self.addSubview(self.dwLabel)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 20
        if #available(iOS 13.0, *) {
            self.backgroundColor =  UIColor.init(dynamicProvider: { (trait) -> UIColor in
                return (trait.userInterfaceStyle == .dark) ? UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1): UIColor.white
            })
        } else {
            self.backgroundColor =  self.picker.backgroundColor
        }
        self.layer.maskedCorners = .init(arrayLiteral: .layerMinXMinYCorner,.layerMaxXMinYCorner)
        
        self.saveButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.height.equalTo(44)
            make.centerX.equalTo(self)
            make.width.equalTo(self).offset(-40).priority(.medium)
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(10)
            make.width.lessThanOrEqualTo(self).offset(-20).priority(.medium)
            make.height.equalTo(30).priority(.medium)
        }
        self.picker.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10).priority(.medium)
            make.bottom.equalTo(self.saveButton.snp.top).offset(-10).priority(.medium)
        }
        self.dwLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self).offset(40)
            make.centerY.equalTo(self.picker)
        }
        self.updateTrait()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var back : UIView = {
        let view =  UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismiss)))
        return view
    }()
    
    lazy var picker : UIPickerView = {
        let picker = UIPickerView.init()
        picker.dataSource = self
        picker.delegate = self
        if #available(iOS 13.0, *) {
            picker.backgroundColor = UIColor.clear
        } else {
            picker.backgroundColor = UIColor.clear
        }
        return picker
    }()
    
    func show(title:String,items:[String],dw:String,defaultIndex:Int,complete: ((Int)->Void)?){
        guard let baseView = UIApplication.shared.keyWindow else {return}
        baseView.addSubview(self.back)
        baseView.addSubview(self)
        let height: CGFloat = 350
        let margin : CGFloat = 3
        self.titleLabel.text = title
        self.dwLabel.text = dw
        self.frame = CGRect.init(x: margin, y: baseView.bounds.maxY, width: baseView.bounds.width - 2 * margin, height: height)
        self.back.frame = baseView.bounds
        self.back.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0,  options: .curveEaseOut, animations: {
            self.frame.origin.y -= self.frame.height
            self.back.alpha = 1
        }) { (_) in
            }
        
        self.items = items
        self.picker.reloadAllComponents()
        self.picker.selectRow(defaultIndex, inComponent: 0, animated: false)
        self.complete = complete
    }
    
    @objc func dismiss(){
        UIView.animate(withDuration: 0.25, delay: 0,  options: .curveEaseIn, animations: {
            self.frame.origin.y += self.frame.height
            self.back.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTrait()
    }
    
    func updateTrait(){
        if #available(iOS 13.0, *) {
            self.saveButton.setTitleColor(UIColor.label, for: .normal)
            let color = (self.traitCollection.userInterfaceStyle == .dark) ? UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) : UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            self.saveButton.setBackgroundImage( color.image, for: .normal)
        } else {
            self.saveButton.setTitleColor(UIColor.black, for: .normal)
            self.saveButton.setBackgroundImage(UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).image, for: .normal)
        }
    }
    
    @objc func callBack(){
        self.complete?(self.picker.selectedRow(inComponent: 0))
        self.dismiss()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return self.items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.items[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if self.traitCollection.userInterfaceStyle == .dark {
            if #available(iOS 13.0, *) {
                return NSAttributedString.init(string: self.items[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.label])
            } else {
                return NSAttributedString.init(string: self.items[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            }
        }else{
            return nil
        }
    }
}
