//
//  VisitorView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/7.
//

import UIKit

class VisitorView: UIView{
    private lazy var messageLabel: UILabel = UILabel(title: "关注一些人，回这里看看有什么惊喜关注一些人，回这里看看有什么惊喜")
    private lazy var maskIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    /// 注册按钮
    lazy var registerButton: UIButton = UIButton(title: "注册", color: UIColor.red, backImageName: "common_button_white_disable")
    
    /// 登录按钮
    lazy var loginButton: UIButton = UIButton(title: "登录", color: UIColor.darkText, backImageName: "common_button_white_disable")
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    private lazy var homeIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
/*
import Foundation
import UIKit
 
class GradientCustomView: UIView {
    
    @IBInspectable var isGradient: Bool = false
    @IBInspectable var startColor: UIColor = .white
    @IBInspectable var endColor: UIColor = .white
    @IBInspectable var locations: [NSNumber] = [0 , 1]
    @IBInspectable var startPoint: CGPoint = .zero
    @IBInspectable var endPoint: CGPoint = .zero
    
    private var gradientBGLayer: CAGradientLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBGLayer?.removeFromSuperlayer()
        if isGradient {
            gradientBGLayer = CAGradientLayer()
            gradientBGLayer!.colors = [startColor.cgColor, endColor.cgColor]
            gradientBGLayer!.locations = locations
            gradientBGLayer!.frame = bounds
            gradientBGLayer!.startPoint = startPoint
            gradientBGLayer!.endPoint = endPoint
            self.layer.insertSublayer(gradientBGLayer!, at: 0)
        }
    }
 
}
 */
import Foundation
import UIKit
 
extension UIView {
    
    @discardableResult
    func addGradient(colors: [UIColor],
                     point: (CGPoint, CGPoint) = (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1)),
                     locations: [NSNumber] = [0, 1],
                     frame: CGRect = CGRect.zero,
                     radius: CGFloat = 0,
                     at: UInt32 = 0) -> CAGradientLayer {
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = colors.map { $0.cgColor }
        bgLayer1.locations = locations
        if frame == .zero {
            bgLayer1.frame = self.bounds
        } else {
            bgLayer1.frame = frame
        }
        bgLayer1.startPoint = point.0
        bgLayer1.endPoint = point.1
        bgLayer1.cornerRadius = radius
        self.layer.insertSublayer(bgLayer1, at: at)
        return bgLayer1
    }
    
    func addGradient(start: CGPoint = CGPoint(x: 0.5, y: 0),
                     end: CGPoint = CGPoint(x: 0.5, y: 1),
                     colors: [UIColor],
                     locations: [NSNumber] = [0, 1],
                     frame: CGRect = CGRect.zero,
                     radius: CGFloat = 0,
                     at: UInt32 = 0) {
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = colors.map { $0.cgColor }
        bgLayer1.locations = locations
        bgLayer1.frame = frame
        bgLayer1.startPoint = start
        bgLayer1.endPoint = end
        bgLayer1.cornerRadius = radius
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    
    func addGradient(start_color:String,end_color : String,frame : CGRect?=nil,cornerRadius : CGFloat?=0, at: UInt32 = 0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(named: start_color)!.cgColor, UIColor(named: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: 0.61)
        bgLayer1.endPoint = CGPoint(x: 0.61, y: 0.61)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    
    func addGradient(start_color:String,
                     end_color : String,
                     frame : CGRect?=nil,
                     borader: CGFloat = 0,
                     boraderColor: UIColor = .clear,
                     at: UInt32 = 0,
                     corners: UIRectCorner?,
                     radius: CGFloat = 0) {
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(named: start_color)!.cgColor, UIColor(named: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: 0.61)
        bgLayer1.endPoint = CGPoint(x: 0.61, y: 0.61)
        bgLayer1.borderColor = boraderColor.cgColor
        bgLayer1.borderWidth = borader
        if corners != nil {
            let cornerPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners!, cornerRadii: CGSize(width: radius, height: radius))
            let radiusLayer = CAShapeLayer()
            radiusLayer.frame = bounds
            radiusLayer.path = cornerPath.cgPath
            bgLayer1.mask = radiusLayer
        }
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    
    func addGradient(startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
                     start_color:String,
                     endPoint: CGPoint = CGPoint(x: 1, y: 0.5),
                     end_color : String,
                     frame : CGRect? = nil,
                     cornerRadius : CGFloat?=0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.frame = bounds
        bgLayer1.startPoint = startPoint
        bgLayer1.endPoint = endPoint
        bgLayer1.colors = [UIColor(named: start_color)!.cgColor, UIColor(named: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.addSublayer(bgLayer1)
    }
    
    func addVerticalGradient(start_color:String,end_color : String,frame : CGRect?=nil,cornerRadius : CGFloat?=0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(named: start_color)!.cgColor, UIColor(named: end_color)!.cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.insertSublayer(bgLayer1, at: 0)
    }
    
    //将当前视图转为UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
extension VisitorView {
    private func setupUI() {
        addSubview(homeIconView)
        addSubview(maskIconView)
        addSubview(iconView)
        addSubview(messageLabel)
        messageLabel.textColor = UIColor(white: 0.3, alpha: 1.0)
        addSubview(registerButton)
        addSubview(loginButton)
        iconView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-60)
        }
        homeIconView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(iconView.snp.center)
        }
        messageLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(iconView.snp.centerX)
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.width.equalTo(224)
            make.height.equalTo(36)
        }
        registerButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(messageLabel.snp.left)
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        loginButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(messageLabel.snp.right)
            make.top.equalTo(registerButton.snp.top)
            make.width.equalTo(registerButton.snp.width)
            make.height.equalTo(registerButton.snp.height)
        }
        maskIconView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(registerButton.snp.bottom)
        }
        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
    private func startAnim() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 20
        anim.isRemovedOnCompletion = false
        iconView.layer.add(anim, forKey: nil)
    }
    func setupInfo(imageName: String?, title: String) {
        messageLabel.text = title
        guard let imgName = imageName else {
            startAnim()
            return
        }
        homeIconView.isHidden = true
        sendSubviewToBack(maskIconView)
        iconView.image = UIImage(named: imgName)
    }
}
extension VisitorView {
    func visitorViewDidRegister() {
        let vc = OAuthViewController(.注册)
        _ = UINavigationController(rootViewController: vc)
    }
    func visitorViewDidLogin() {
        let vc = OAuthViewController(.登录)
        _ = UINavigationController(rootViewController: vc)
    }
}
