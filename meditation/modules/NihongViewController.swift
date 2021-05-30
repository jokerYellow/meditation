//
//  NihongViewController.swift
//  meditation
//
//  Created by HuangYaqing on 2021/5/30.
//  Copyright © 2021 HuangYaqing. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func snapshotView(scale scale: CGFloat = 0.0, isOpaque: Bool = true) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, isOpaque, scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func blur(blurRadius blurRadius: CGFloat) -> UIImage?
    {
        guard let blur = CIFilter(name: "CIGaussianBlur") else { return nil }

        let image = self.snapshotView(scale: 1.0, isOpaque: true)
        blur.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)

        let ciContext  = CIContext(options: nil)

        let result = blur.value(forKey: kCIOutputImageKey) as! CIImage

        let boundingRect = CGRect(x: 0,
                                  y: 0,
                                  width: frame.width,
                                  height: frame.height)

        let cgImage = ciContext.createCGImage(result, from: boundingRect)!

        return UIImage(cgImage: cgImage)
    }
}

let shenseColor =  UIColor.init(red: 142.0/255.0, green: 41.0/255.0, blue: 84.0/255.0, alpha: 1)

let qianseColor = UIColor.init(red: 1, green: 167.0/255.0, blue: 201.0/255.0, alpha: 1)

let blueShenseColor =  UIColor.init(red: 55.0/255.0, green: 175.0/255.0, blue: 219.0/255.0, alpha: 1)

let blueQianseColor = UIColor.init(red: 128.0/255.0, green: 211.0/255.0, blue: 243.0/255.0, alpha: 1)

func generateLabel(isEmpty:Bool = true)->UILabel{
    let label = UILabel()
    label.frame = CGRect(x: 30, y: 200, width: 300, height: 130)
    
    let shadow = NSShadow()
    shadow.shadowBlurRadius = 2
    shadow.shadowColor = UIColor.white
    shadow.shadowOffset = .init(width: 0, height: 0)
    let strokeTextAttributes = isEmpty ?  [
        NSAttributedString.Key.foregroundColor : isEmpty ? UIColor.clear : blueShenseColor,
        NSAttributedString.Key.strokeColor : blueShenseColor,
        NSAttributedString.Key.strokeWidth : 1.0,
        .shadow:shadow,
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 60, weight: UIFont.Weight.heavy)
            
    ] as [NSAttributedString.Key : Any] :  [
        NSAttributedString.Key.foregroundColor : isEmpty ? UIColor.clear : blueShenseColor,
        .shadow:shadow,
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 60, weight: UIFont.Weight.heavy)
            
    ] as [NSAttributedString.Key : Any]
    label.layer.borderWidth = 3
    label.layer.borderColor = shenseColor.cgColor
    label.layer.cornerRadius = 10
    label.textAlignment = .center
    label.attributedText = NSAttributedString.init(string: "旺角冰室", attributes: strokeTextAttributes)
    
    return label
}

class MyViewController : UIViewController {
    
    let content :UILabel = generateLabel()
    
    let contentBack :UILabel = generateLabel()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        ciimageWay()
    }
    
    func ciimageWay(){
        let backView = UIView.init(frame: self.view.bounds)
        let back = generateLabel(isEmpty: false)
        backView.addSubview(back)
        
        let content = generateLabel(isEmpty: true)
        view.addSubview(content)
        let image = backView.blur(blurRadius: 7)
        let imageView = UIImageView.init(image: image)
        imageView.frame = self.view.frame
        imageView.clipsToBounds = false
        imageView.layer.add(animation(), forKey: "opacity")
        self.view.insertSubview(imageView, at: 0)
    }
    
    func animation() -> CAAnimation {
        let animate = CABasicAnimation.init(keyPath: "opacity")
        animate.fromValue = 1
        animate.toValue = 0.5
        animate.duration = 0.45
        animate.repeatCount = 1000
        animate.autoreverses = true
        animate.isRemovedOnCompletion = false
        return animate
    }
    
    func blurViewWay() {
        self.content.alpha = 0.8
        self.contentBack.layer.shadowRadius = 3
        self.contentBack.layer.shadowOpacity = 3
        self.contentBack.layer.frame.origin.y += 3
        
        let effect = UIBlurEffect.init(style: .regular)
        let visual = UIVisualEffectView.init(effect: effect)
        view.addSubview(visual)
        visual.frame = view.bounds
        view.addSubview(self.contentBack)
        view.addSubview(self.content)
    }
    
}
