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

private let animationSize = CGSize.init(width: 200, height: 200)

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

private enum AnimateType{
    case eight
    case sixteen
    case round
    case random
}

class ViewController: UIViewController {
    static let buttonHeight :CGFloat = 40
    let button :UIButton = {
        let b = UIButton.init()
        b.setBackgroundImage(UIImage.image(color: UIColor.white), for: .normal)
        b.setTitle("开始", for: .normal)
        b.setTitleColor(UIColor.black, for: .normal)
        b.layer.cornerRadius = ViewController.buttonHeight*0.5
        b.layer.masksToBounds = true
        b.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        b.contentEdgeInsets = .init(top: 0, left: 30, bottom: 0, right: 30)
        return b
    }()
    
    let backImage : UIImageView = {
        let image = UIImageView()
        image.image = R.image.background()
        return image
    }()
    
    let animation : CAShapeLayer = CAShapeLayer()
    
    let animationView = UIView()
     
    let settingButton = UIButton.init()
    
    let timerLabel = UILabel()
    
    let meditation = Meditation.shared
    
    var state: Meditation.State!
    
    var isStoping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.backImage)
        self.backImage.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.view.addSubview(self.button)
        
        self.button.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.height.equalTo(ViewController.buttonHeight)
            make.centerX.equalTo(self.view)
        }
        
        self.view.addSubview(self.animationView)
        self.animationView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(150)
            make.centerX.equalTo(self.view)
            make.size.equalTo(animationSize)
        }
        self.animationView.layer.addSublayer(self.animation)
        
        self.animation.frame = CGRect.init(x: 0, y: 0, width: animationSize.width, height: animationSize.height)
        self.animation.fillColor = UIColor.clear.cgColor
        self.animation.lineWidth = 3
        self.animation.strokeColor = UIColor.white.cgColor
        self.animation.path = self.circlePath(radius: Double(animationSize.width)*0.5, type: .eight)
        
        self.button.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        self.settingButton.setImage(R.image.setting(), for: .normal)
        self.settingButton.addTarget(self, action: #selector(gotoSetting), for: .touchUpInside)
        self.view.addSubview(self.settingButton)
        self.settingButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-10)
            make.size.equalTo(CGSize.init(width: 44, height: 44))
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        self.meditation.stateCallBack = { [weak self]state in
            self?.refreshState(state: state)
        }
        self.animationView.addSubview(self.timerLabel)
        self.timerLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.animationView)
        } 
        // Do any additional setup after loading the view.
    }
    
    @objc func gotoSetting() {
        self.present(UINavigationController.init(rootViewController: SettingViewController()), animated: true, completion: nil)
    }
    
    func refreshState(state:Meditation.State){
        defer {
            self.state = state
        }
        if isStoping {
            return
        }
        switch state {
        case .wait:
            if let s = self.state, s != state{
                self.stopWork()
                return
            }
            self.timerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        case .isWorking:
            self.timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
            if self.state != state{
                self.beginAnimation()
            }
        case .isBreak:
            self.timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
        }
        self.button.setTitle(state.title, for: .normal)
        self.timerLabel.text = state.lastTime
        self.timerLabel.textColor = UIColor.white
    }
    
    @objc func click() -> Void {
        self.meditation.trigger()
    }
    
    func stopWork(){
        self.button.isEnabled = false
        self.isStoping = true
        let duration : TimeInterval = 0.25
        UIView.animate(withDuration: duration, animations: {
            self.animationView.alpha = 0
            self.animation.shadowOpacity = 0
        }) { (_) in
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.animation.removeAllAnimations()
            self.isStoping = false
            self.refreshState(state: self.meditation.state)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.animationView.alpha = 1
            }, completion: { (_) in
                self.button.isEnabled = true
            })
        }
    }

    func beginAnimation()  {
        let key = CAKeyframeAnimation()
        key.keyPath = "path"
        key.duration = 30
        key.repeatCount = Float.greatestFiniteMagnitude
        key.isRemovedOnCompletion = false
        key.fillMode = CAMediaTimingFillMode.both

        let first = self.circlePath(radius: Double(animationSize.width)*0.5,type: .eight)
        key.values = [
            first,
            self.circlePath(radius: Double(animationSize.width)*0.5,type: .sixteen),
            first, 
        ]
        
        let rotate = CAKeyframeAnimation()
        rotate.keyPath = "transform.rotation.z"
        rotate.duration = 30
        rotate.repeatCount = Float.greatestFiniteMagnitude
        rotate.isRemovedOnCompletion = false
        rotate.values = [
            0,
            Float.pi*1,
            Float.pi*2,
        ]
        rotate.fillMode = CAMediaTimingFillMode.both
        
        let lineWidth = CAKeyframeAnimation()
        lineWidth.keyPath = "lineWidth"
        lineWidth.duration = 30
        lineWidth.repeatCount = Float.greatestFiniteMagnitude
        lineWidth.isRemovedOnCompletion = false
        lineWidth.values = [
            3,
            1,
            3,
        ]
        
        let shadowWidth = CAKeyframeAnimation()
        shadowWidth.keyPath = "shadowRadius"
        shadowWidth.duration = 10
        shadowWidth.repeatCount = Float.greatestFiniteMagnitude
        shadowWidth.isRemovedOnCompletion = false
        shadowWidth.fillMode = CAMediaTimingFillMode.both
        shadowWidth.values = [
            10,
            4,
            10,
        ]
        
        
        let scale = CAKeyframeAnimation()
        scale.keyPath = "transform.scale"
        scale.duration = 30
        scale.repeatCount = Float.greatestFiniteMagnitude
        scale.isRemovedOnCompletion = false
        scale.fillMode = CAMediaTimingFillMode.both
        scale.values = [
            1,
            1.1,
            0.9,
            1.1,
            1,
        ]
        
        self.animation.shadowOpacity = 0.3
        self.animation.shadowColor = UIColor.black.cgColor
        
        self.animation.add(key, forKey: nil)
        self.animation.add(rotate, forKey: nil)
        self.animation.add(lineWidth, forKey: nil)
        self.animation.add(shadowWidth, forKey: nil)
        self.animation.add(scale, forKey: nil)
    }
    
    private func circlePath(radius:Double,type:AnimateType) -> CGPath {
        if type == .round{
            return CGPath.init(ellipseIn: CGRect.init(x: 0, y: 0, width: radius*2, height: radius*2), transform: nil)
        }
        let pi = 3.1419
        let path = UIBezierPath.init()
        let g2:Double = 1.414
        let g2radius = Double(radius*(g2-1)/g2)
        
        let p1 = CGPoint.init(x: g2radius, y: g2radius)
        let p2 = CGPoint.init(x: Double(radius), y: 0.0)
        let p3 = CGPoint.init(x: 2*radius - g2radius, y: g2radius)
        let p4 = CGPoint.init(x: 2*radius, y: radius)
        let p5 = CGPoint.init(x: 2*radius - g2radius, y: 2*radius - g2radius)
        let p6 = CGPoint.init(x: radius, y: 2*radius)
        let p7 = CGPoint.init(x: g2radius, y: 2*radius - g2radius)
        let p8 = CGPoint.init(x: 0, y: radius)
        
        let p12 = CGPoint.init(x: radius*(1-sin(22.5/180.0*pi)), y: radius*(1-cos(22.5/180.0*pi)))
        let p23 = CGPoint.init(x: radius*(1+sin(22.5/180.0*pi)), y: radius*(1-cos(22.5/180.0*pi)))
        let p34 = CGPoint.init(x: radius*(1+cos(22.5/180.0*pi)), y: radius*(1-sin(22.5/180.0*pi)))
        let p45 = CGPoint.init(x: radius*(1+cos(22.5/180.0*pi)), y: radius*(1+sin(22.5/180.0*pi)))
        let p56 = CGPoint.init(x: radius*(1+sin(22.5/180.0*pi)), y: radius*(1+cos(22.5/180.0*pi)))
        let p67 = CGPoint.init(x: radius*(1-sin(22.5/180.0*pi)), y: radius*(1+cos(22.5/180.0*pi)))
        let p78 = CGPoint.init(x: radius*(1-cos(22.5/180.0*pi)), y: radius*(1+sin(22.5/180.0*pi)))
        let p81 = CGPoint.init(x: radius*(1-cos(22.5/180.0*pi)), y: radius*(1-sin(22.5/180.0*pi)))
        
        let origin = p1
        path.move(to: origin)
        if type == .eight {
            path.addLine(to: midOf(p1: p1, p2: p2))
            path.addLine(to: p2)
            path.addLine(to: midOf(p1: p2, p2: p3))
            path.addLine(to: p3)
            path.addLine(to: midOf(p1: p3, p2: p4))
            path.addLine(to: p4)
            path.addLine(to: midOf(p1: p4, p2: p5))
            path.addLine(to: p5)
            path.addLine(to: midOf(p1: p5, p2: p6))
            path.addLine(to: p6)
            path.addLine(to: midOf(p1: p6, p2: p7))
            path.addLine(to: p7)
            path.addLine(to: midOf(p1: p7, p2: p8))
            path.addLine(to: p8)
            path.addLine(to: midOf(p1: p8, p2: p1))
            path.addLine(to: p1)
        }else if type == .sixteen{
            path.addLine(to: p12)
            path.addLine(to: p2)
            path.addLine(to: p23)
            path.addLine(to: p3)
            path.addLine(to: p34)
            path.addLine(to: p4)
            path.addLine(to: p45)
            path.addLine(to: p5)
            path.addLine(to: p56)
            path.addLine(to: p6)
            path.addLine(to: p67)
            path.addLine(to: p7)
            path.addLine(to: p78)
            path.addLine(to: p8)
            path.addLine(to: p81)
            path.addLine(to: p1)
        }
        path.close()
        return path.cgPath
    }
    
    func randomPoint(_ p:CGPoint) -> CGPoint {
        let r = randomRadius()
        return CGPoint.init(x: Double(p.x) * r, y: Double(p.y) * r)
    }
    
    func randomRadius() -> Double {
        return Double.random(in: 1.0..<1.2)
    }
    
    func midOf(p1:CGPoint,p2:CGPoint) -> CGPoint{
        return CGPoint.init(x: p1.x + (p2.x - p1.x)*0.5, y: p1.y + (p2.y - p1.y)*0.5)
    }
}
