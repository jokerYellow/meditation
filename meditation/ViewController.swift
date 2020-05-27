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

private let animationSize = CGSize.init(width: 100, height: 100)

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
         
        self.view.layer.addSublayer(self.animation)
        
        self.animation.frame = CGRect.init(x: (self.view.frame.width - animationSize.width)*0.5, y: 100, width: animationSize.width, height: animationSize.height)
        self.animation.fillColor = UIColor.clear.cgColor
        self.animation.lineWidth = 1
        self.animation.strokeColor = UIColor.white.cgColor
        self.beginAnimation()
        // Do any additional setup after loading the view.
    }

    func beginAnimation()  {
        let key = CAKeyframeAnimation()
        key.keyPath = "path"
        key.duration = 10
        key.repeatCount = Float.greatestFiniteMagnitude
        key.isRemovedOnCompletion = true
        key.fillMode = CAMediaTimingFillMode.both

        let first = self.circlePath(radius: Double(animationSize.width)*0.5)
        key.values = [
            first,
            self.circlePath(radius: Double(animationSize.width)*0.5),
            self.circlePath(radius: Double(animationSize.width)*0.5),
            self.circlePath(radius: Double(animationSize.width)*0.5),
            self.circlePath(radius: Double(animationSize.width)*0.5),
            first,
        ]
        
        let rotate = CAKeyframeAnimation()
        rotate.keyPath = "transform.rotation.z"
        rotate.duration = 12
        rotate.repeatCount = Float.greatestFiniteMagnitude
        rotate.isRemovedOnCompletion = false
        rotate.values = [
            0,
            Float.pi*1,
            Float.pi*2,
        ]
        
        self.animation.add(key, forKey: nil)
//        self.animation.add(rotate, forKey: nil)
    }
    
    func circlePath(radius:Double) -> CGPath {
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
        
        let origin = p1
        path.move(to: origin)
        
        path.addQuadCurve(to: p2, controlPoint: CGPoint.init(x: radius*(1-sin(22.5/180.0*Double(Float.pi))), y: radius*(1-cos(22.5/180.0*Double(Float.pi)))))
        
        path.addQuadCurve(to: p3, controlPoint: CGPoint.init(x: radius*(1+sin(22.5/180.0*Double(Float.pi))), y: radius*(1-cos(22.5/180.0*Double(Float.pi)))))
        
        path.addQuadCurve(to: p4, controlPoint: CGPoint.init(x: radius*(1+cos(22.5/180.0*Double(Float.pi))), y: radius*(1-sin(22.5/180.0*Double(Float.pi)))))
        path.addQuadCurve(to: p5, controlPoint: CGPoint.init(x: radius*(1+cos(22.5/180.0*Double(Float.pi))), y: radius*(1+sin(22.5/180.0*Double(Float.pi)))))
        
        path.addQuadCurve(to: p6, controlPoint: CGPoint.init(x: radius*(1+sin(22.5/180.0*Double(Float.pi))), y: radius*(1+cos(22.5/180.0*Double(Float.pi)))))
        path.addQuadCurve(to: p7, controlPoint: CGPoint.init(x: radius*(1-sin(22.5/180.0*Double(Float.pi))), y: radius*(1+cos(22.5/180.0*Double(Float.pi)))))
        
        path.addQuadCurve(to: p8, controlPoint: CGPoint.init(x: radius*(1-cos(22.5/180.0*Double(Float.pi))), y: radius*(1+sin(22.5/180.0*Double(Float.pi)))))
        
        path.addQuadCurve(to: origin, controlPoint: CGPoint.init(x: radius*(1-cos(22.5/180.0*Double(Float.pi))), y: radius*(1-sin(22.5/180.0*Double(Float.pi)))))
        
        return path.cgPath
    }
    
    func randomPoint(_ p:CGPoint) -> CGPoint {
        return CGPoint.init(x: Double(p.x) * randomRadius(), y: Double(p.y)*randomRadius())
    }
    
    func randomRadius() -> Double {
        return Double.random(in: 0.9..<1.1)
    }
    
}
