//
//  NihongClockViewController.swift
//  meditation
//
//  Created by HuangYaqing on 2021/5/30.
//  Copyright © 2021 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class NihongClockViewController: UIViewController   {
 
    let timeLabel =  UILabel()
    let border = CAShapeLayer()
    let startButton :UIButton = {
        let button = UIButton.init(type: .custom)
        let font = UIFont.init(name: "Hiragino Maru Gothic ProN", size: 20) ?? UIFont.systemFont(ofSize: 20)
        let strokeTextAttributes =  [
            NSAttributedString.Key.foregroundColor :  blueShenseColor,
            NSAttributedString.Key.font : font
        ] as [NSAttributedString.Key : Any]
        
        let highlightStrokeTextAttributes =  [
            NSAttributedString.Key.foregroundColor :  blueQianseColor,
            NSAttributedString.Key.font : font
        ] as [NSAttributedString.Key : Any]
        
        button.setAttributedTitle(NSAttributedString.init(string: NSLocalizedString("开始", comment: "开始番茄钟按钮"), attributes: strokeTextAttributes), for: .normal)
        button.setAttributedTitle(NSAttributedString.init(string: NSLocalizedString("开始", comment: "开始番茄钟按钮"), attributes: highlightStrokeTextAttributes), for: .highlighted)
        return button
    }()
    
    let nihongLayer = UIView()
    
    let dot = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(nihongLayer)
        self.border.backgroundColor = UIColor.clear.cgColor
        self.border.fillColor = UIColor.clear.cgColor
        nihongLayer.layer.addSublayer(self.border)
        nihongLayer.addSubview(self.timeLabel)
        nihongLayer.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.border.addSublayer(self.dot)
        self.timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(nihongLayer)
            make.top.equalTo(nihongLayer).offset(200)
        }
        self.setText(content: "23:22", isEmpty: false, label: self.timeLabel)
        nihongLayer.addSubview(self.startButton)
        self.startButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(nihongLayer).offset(-200)
            make.centerX.equalTo(nihongLayer)
        }
        DispatchQueue.main.async {
//            self.renderNihong(radius: 10.0)
            self.renderNihong(radius: 5.0)
//            self.renderNihong(radius: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.setText(content: "23:22", isEmpty: true, label: self.timeLabel)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.dot.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 2, height: 2))
            self.dot.cornerRadius = 1
            self.dot.backgroundColor = blueQianseColor.cgColor
            self.dot.shadowColor = blueShenseColor.cgColor
            self.dot.shadowRadius = 2
            self.dot.shadowOpacity = 1
            self.dot.shadowPath = CGPath.init(rect: CGRect.init(x: -2, y: 1, width:6, height: 6), transform: nil)
            let animation = CAKeyframeAnimation.init(keyPath: "position")
            animation.path = self.border.path
            animation.timeOffset = 15
            animation.repeatCount = 1000
            animation.isRemovedOnCompletion = false
            animation.duration = 60
            animation.calculationMode = .paced
            self.dot.add(animation, forKey: "position")
        }
    }
    
    func renderNihong(radius:CGFloat) {
        let size = CGSize.init(width: nihongLayer.frame.width, height: nihongLayer.frame.height)
        guard   let context : CGContext = CGContext.init(data: nil,
                                                       width: Int(size.width),
                                                       height: Int(size.height),
                                                       bitsPerComponent: 8,
                                                       bytesPerRow: 0,
                                                       space: CGColorSpaceCreateDeviceRGB(),
                                                       bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        else {
            return
        }
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        nihongLayer.layer.render(in: context)
        guard let image = context.makeImage() else {
            return
        }
        guard let blur = CIFilter(name: "CIGaussianBlur") else { return }
        
        let ciimage = CIImage.init(cgImage: image)
        blur.setValue(ciimage, forKey: kCIInputImageKey)
        blur.setValue(radius, forKey: kCIInputRadiusKey)

        let ciContext  = CIContext(options: nil)

        let boundingRect = CGRect(x: 0,
                                  y: 0,
                                  width: size.width,
                                  height: size.height)

        guard let result = blur.value(forKey: kCIOutputImageKey) as? CIImage,
              let cgImage = ciContext.createCGImage(result, from: boundingRect) else {return}
        let outImage =  UIImage.init(cgImage: cgImage)
        let backLayer = UIImageView()
        backLayer.frame = nihongLayer.bounds
        backLayer.image = outImage
        backLayer.alpha = 1
        backLayer.layer.add(animation(), forKey: nil)
        border.add(animation(), forKey: nil)
        timeLabel.layer.add(animation(), forKey: nil)
        nihongLayer.insertSubview(backLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        border.frame = self.timeLabel.frame.insetBy(dx: -15, dy: -10)
        let path = CGPath.init(roundedRect: border.bounds, cornerWidth: 10, cornerHeight: 10, transform: nil)
        border.path = path
        border.strokeColor = UIColor.red.cgColor
        border.lineWidth = 2
        border.strokeStart = 0
        border.strokeEnd = 1
    }
    
    func setText(content:String,isEmpty:Bool = true,label:UILabel) {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = UIColor.white
        shadow.shadowOffset = .init(width: 0, height: 0)
        let font = UIFont.init(name: "Hiragino Maru Gothic ProN", size: 60) ?? UIFont.systemFont(ofSize: 60)
        let strokeTextAttributes = isEmpty ?  [
            NSAttributedString.Key.foregroundColor : isEmpty ? UIColor.clear : blueShenseColor,
            NSAttributedString.Key.strokeColor : blueShenseColor,
            NSAttributedString.Key.strokeWidth : 1.0,
            NSAttributedString.Key.font : font
        ] as [NSAttributedString.Key : Any] :  [
            NSAttributedString.Key.foregroundColor : isEmpty ? UIColor.clear : blueShenseColor,
//            .shadow:shadow,
            NSAttributedString.Key.font : font
                
        ] as [NSAttributedString.Key : Any]
        label.textAlignment = .center
        label.attributedText = NSAttributedString.init(string: content, attributes: strokeTextAttributes)
    }
    
    func animation() -> CAAnimation {
        let animate = CABasicAnimation.init(keyPath: "opacity")
        animate.fromValue = 1
        animate.toValue = 0.4
        animate.duration = 1
        animate.repeatCount = 1000
        animate.autoreverses = true
        animate.timingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
        animate.isRemovedOnCompletion = false
        return animate
    }
}
