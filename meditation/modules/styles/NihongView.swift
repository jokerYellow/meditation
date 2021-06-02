//
//  NihongView.swift
//  meditation
//
//  Created by HuangYaqing on 2021/5/31.
//  Copyright © 2021 HuangYaqing. All rights reserved.
//

import UIKit


let shenseColor =  UIColor.init(red: 142.0/255.0, green: 41.0/255.0, blue: 84.0/255.0, alpha: 1)

let qianseColor = UIColor.init(red: 1, green: 167.0/255.0, blue: 201.0/255.0, alpha: 1)

let blueShenseColor =  UIColor.init(red: 55.0/255.0, green: 175.0/255.0, blue: 219.0/255.0, alpha: 1)

let blueQianseColor = UIColor.init(red: 128.0/255.0, green: 211.0/255.0, blue: 243.0/255.0, alpha: 1)


let font = UIFont.init(name: "Hiragino Maru Gothic ProN", size: 20) ?? UIFont.systemFont(ofSize: 20)
let strokeTextAttributes =  [
    NSAttributedString.Key.foregroundColor :  blueShenseColor,
    NSAttributedString.Key.font : font
    ] as [NSAttributedString.Key : Any]
let highlightStrokeTextAttributes =  [
    NSAttributedString.Key.foregroundColor :  blueQianseColor,
    NSAttributedString.Key.font : font
    ] as [NSAttributedString.Key : Any]

class NihongView: UIView {
    
    static func button()->UIButton{
        let button = UIButton.init(type: .custom)
        button.setAttributedTitle(NSAttributedString.init(string: NSLocalizedString("begin", comment: "开始"), attributes: strokeTextAttributes), for: .normal)
        button.setAttributedTitle(NSAttributedString.init(string: NSLocalizedString("begin", comment: "开始"), attributes: highlightStrokeTextAttributes), for: .highlighted)
        return button
    }
    
    
    let timeLabel =  UILabel()
    let border = CAShapeLayer()
    let button :UIButton =  NihongView.button()
   
    let nihongLayer = UIView()
   
    let dot = CALayer()
    let meditation = Meditation.shared
    
    var state: Meditation.State!
    
    var isStoping = false
    let backLayer = UIImageView()
    
    let nihongCopy = UIView()
    let dotCopy = CALayer()
    let borderCopy = CAShapeLayer()
    let buttonCopy : UIButton = NihongView.button()
    let timeLabelCopy =  UILabel()
    let separeteView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.addSubview(nihongLayer)
        self.border.backgroundColor = UIColor.clear.cgColor
        self.border.fillColor = UIColor.clear.cgColor
        nihongLayer.layer.addSublayer(self.border)
        nihongLayer.addSubview(self.timeLabel)
        nihongLayer.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        separeteView.backgroundColor = UIColor.black
        self.insertSubview(backLayer, at: 0)
        self.border.addSublayer(self.dot)
        self.timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(nihongLayer)
            make.top.equalTo(nihongLayer).offset(200)
            make.width.greaterThanOrEqualTo(200)
            make.height.greaterThanOrEqualTo(60)
        }
        nihongLayer.addSubview(self.button)
        self.button.snp.makeConstraints { (make) in
            make.bottom.equalTo(nihongLayer).offset(-200)
            make.centerX.equalTo(nihongLayer)
        }
        self.meditation.addStateCallBack(callBack: { [weak self]state in
            self?.refreshState(state: state)
        })
        self.button.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        self.nihongCopy.layer.addSublayer(self.borderCopy)
        self.nihongCopy.addSubview(self.buttonCopy)
        self.nihongCopy.addSubview(timeLabelCopy)
        self.timeLabelCopy.snp.makeConstraints { (make) in
            make.centerX.equalTo(nihongCopy)
            make.top.equalTo(nihongCopy).offset(200)
            make.width.greaterThanOrEqualTo(200)
            make.height.greaterThanOrEqualTo(60)
        }
        self.buttonCopy.snp.makeConstraints { (make) in
            make.bottom.equalTo(nihongCopy).offset(-200)
            make.centerX.equalTo(nihongCopy)
        }
        self.insertSubview(self.nihongCopy, at: 0)
        self.insertSubview(self.separeteView, at: 1)
        self.nihongCopy.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        self.separeteView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func refreshState(state:Meditation.State){
        defer {
            self.state = state
        }
        if isStoping {
            return
        }
        button.setAttributedTitle(NSAttributedString.init(string: state.title, attributes: strokeTextAttributes), for: .normal)
        button.setAttributedTitle(NSAttributedString.init(string: state.title, attributes: highlightStrokeTextAttributes), for: .highlighted)
        let refresh :(CGFloat,Bool)->Void = { (fontSize,isEmpty) in
            self.setText(content: state.lastTime,isEmpty: isEmpty, label: self.timeLabel,fontsize:fontSize)
            self.setText(content: state.lastTime,isEmpty: false, label: self.timeLabelCopy,fontsize:fontSize)
            self.renderNihong(radius: 6)
        }
        switch state {
        case .wait:
            if let s = self.state, s != state{
                self.stopWork()
                return
            }
            refresh(40,false)
        case .isWorking, .isBreak:
            var isEmpty = false
            if case .isBreak(_,_,_) = state {
                isEmpty = false
            }
            refresh(60, isEmpty)
            if self.state != state{
                self.beginAnimation()
            }
        }

    }
    
    @objc func click() -> Void {
        self.meditation.trigger()
    }
    
    func stopWork(){
        self.button.isEnabled = false
        self.isStoping = true
        self.dot.opacity = 0;
        let duration : TimeInterval = 0.5
        UIView.animate(withDuration: duration, animations: {
            self.timeLabel.alpha = 0
            self.backLayer.alpha = 0
        }) { (_) in
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.backLayer.layer.removeAllAnimations()
            self.dot.removeAllAnimations()
            self.border.removeAllAnimations()
            self.isStoping = false
            self.refreshState(state: self.meditation.state)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.timeLabel.alpha = 1
            }, completion: { (_) in
                self.button.isEnabled = true
            })
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginAnimation()  {
        self.dot.opacity = 1;
        backLayer.layer.add(animation(), forKey: nil)
        border.add(animation(), forKey: nil)
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
    
    func renderNihong(radius:CGFloat) {
        let size = CGSize.init(width: nihongCopy.frame.width, height: nihongCopy.frame.height)
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
        nihongCopy.layer.render(in: context)
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
        backLayer.frame = nihongCopy.bounds
        backLayer.image = outImage
        backLayer.alpha = 0
    }
    

    override func layoutSubviews() {
        border.frame = self.timeLabel.frame.insetBy(dx: -15, dy: -10)
        let path = CGPath.init(roundedRect: border.bounds, cornerWidth: 10, cornerHeight: 10, transform: nil)
        border.path = path
        border.strokeColor = UIColor.red.cgColor
        border.lineWidth = 2
        border.strokeStart = 0
        border.strokeEnd = 1
        
        borderCopy.frame = border.frame
        borderCopy.path = border.path
        borderCopy.strokeColor = border.strokeColor
        borderCopy.lineWidth = border.lineWidth
        borderCopy.strokeStart = border.strokeStart
        borderCopy.strokeEnd = border.strokeEnd
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setText(content:String,isEmpty:Bool = true,label:UILabel,fontsize:CGFloat = 60) {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = UIColor.white
        shadow.shadowOffset = .init(width: 0, height: 0)
        let font = UIFont.init(name: "Hiragino Maru Gothic ProN", size: fontsize) ?? UIFont.systemFont(ofSize: fontsize)
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
