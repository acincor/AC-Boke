//
//  VisitorView.swift
//  AC博客
//
//  Created by AC on 2022/9/7.
//

import UIKit

class VisitorView: UIView{
    private lazy var messageLabel: UILabel = UILabel(title: NSLocalizedString("登陆一下，随时随地发现新鲜事", comment: ""))
    private lazy var maskIconView: UIImageView = UIImageView(image: .visitordiscoverFeedMaskSmallicon)
    /// 注册按钮
    lazy var registerButton: UIButton = UIButton(title: NSLocalizedString("注册", comment: ""), color: UIColor.red, backImageName: "common_button_white_disable")
    
    /// 登录按钮
    lazy var loginButton: UIButton = UIButton(title: NSLocalizedString("登录",comment: ""), color: UIColor.darkText, backImageName: "common_button_white_disable")
    private lazy var iconView: UIImageView = UIImageView(image: .visitordiscoverFeedImageSmallicon)
    private lazy var homeIconView: UIImageView = UIImageView(image: .visitordiscoverFeedImageHouse)
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
