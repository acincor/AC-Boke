//
//  WBRefreshControl.swift
//  MHC微博
//
//  Created by mhc team on 2022/11/8.
//

import UIKit
private let WBRefreshControlOffset: CGFloat = -60
class WBRefreshControl: UIRefreshControl {
    private lazy var refreshView = WBRefreshView.refreshView()
    private func setupUI() {
        tintColor = UIColor.clear
        addSubview(refreshView)
        refreshView.snp.makeConstraints { make in
            make.center.equalTo(self.snp.center)
            make.size.equalTo(refreshView.bounds.size)
        }
        DispatchQueue.main.async {
            self.addObserver(self, forKeyPath: "frame", options:[],context: nil)
        }
    }
    deinit {
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    override init() {
        super.init()
        setupUI()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if frame.origin.y > 0 {
            return
        }
        if isRefreshing {
            refreshView.startAnimation()
        }
        if frame.origin.y < WBRefreshControlOffset && !refreshView.rotateFlag {
            //print("反过来")
            refreshView.rotateFlag = true
        } else if frame.origin.y >= WBRefreshControlOffset && refreshView.rotateFlag {
            //print("转过去")
            refreshView.rotateFlag = false
        }
    }
    override func endRefreshing() {
        super.endRefreshing()
        refreshView.stopAnimation()
    }
    override func beginRefreshing() {
        super.beginRefreshing()
        refreshView.startAnimation()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
class WBRefreshView: UIView {
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipIconView: UIImageView!
    func startAnimation() {
        backgroundColor = .clear
        //tipView.backgroundColor = .clear
        tipView.isHidden = true
        //loadingView.isHidden = false
        let key = "transform.rotation"
        if loadingView.layer.animation(forKey: key) != nil {
            return
        }
        let anim = CABasicAnimation(keyPath: key)
        anim.toValue = 2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 0.5
        anim.isRemovedOnCompletion = false
        loadingView.layer.add(anim, forKey: key)
    }
    func stopAnimation() {
        tipView.isHidden = false
        //loadingView.isHidden = true
        loadingView.layer.removeAllAnimations()
    }
    private func rotateTipIcon() {
        UIView.animate(withDuration: 0.5) {
            var angle = CGFloat(Double.pi)
            angle += self.rotateFlag ? -0.0000001 : 0.0000001
            self.tipIconView.transform = CGAffineTransformRotate(self.tipIconView.transform, CGFloat(angle))
        }
    }
    var rotateFlag = false {
        didSet {
            rotateTipIcon()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    class func refreshView() -> WBRefreshView{
        let nib = UINib(nibName: "WBRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil,options: nil)[0] as! WBRefreshView
    }
}
