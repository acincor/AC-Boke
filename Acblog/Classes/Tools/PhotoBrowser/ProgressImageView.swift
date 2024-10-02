//
//  ProgressImageView.swift
//  AC博客
//
//  Created by AC on 2022/11/30.
//

import UIKit

class ProgressImageView: UIImageView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    var progress: CGFloat = 0 {
        didSet {
            progressView.progress = progress
        }
    }
    init() {
        super.init(frame: CGRectZero)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        addSubview(progressView)
        progressView.backgroundColor = .clear
        progressView.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
    }
    private lazy var progressView: ProgressView = ProgressView()
}
private class ProgressView: UIView {
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        let r = min(rect.width, rect.height) * 0.5
        let start = Double.pi / 2
        let end = start + progress * 2 * .pi
        let path = UIBezierPath(arcCenter: center, radius: r, startAngle: start, endAngle: end, clockwise: true)
        path.addLine(to: center)
        path.close()
        UIColor(white: 1.0, alpha: 0.3).setFill()
        path.fill()
    }
}
