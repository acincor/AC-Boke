//
//  TrendCell.swift
//  AC博客
//
//  Created by AC on 2023/9/6.
//

import UIKit

class TrendCell: UICollectionViewCell {
    // 渲染cell的内容
    public var model: String? {
        didSet {
            guard var model = self.model else {
                return
            }
            if model.count > 4 {
                model = String(model.prefix(1))+"..."
            }
            self.subTitleLabel.text = model
        }
    }
    private var subTitleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func deleteTrend() {
        let controller = UIAlertController(title: "创建话题", message: "删除你的话题", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "取消", style: .cancel))
        controller.addAction(UIAlertAction(title: NSLocalizedString("删除",comment: ""), style: .default) { action in
            NetworkTools.shared.deleteTrend(self.model ?? "") { Result, Error in
            }
        }
        )
        NotificationCenter.default.post(name: .init("TrendPresentViewControllerNotification"), object: controller)
    }
    func setupUI() {
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.deleteTrend)))
        self.backgroundColor = .systemFill
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.contentView.addSubview(self.subTitleLabel)
        self.subTitleLabel.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
        self.subTitleLabel.textColor = .systemOrange
        self.subTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        self.subTitleLabel.numberOfLines = 1
    }
}
