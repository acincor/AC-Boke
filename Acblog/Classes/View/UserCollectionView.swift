//
//  UserCollectionView.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit


class UserCollectionView: UIView {
    // MARK: - 懒加载控件
    /// 头像
    private lazy var iconView: UIImageView = UIImageView(image:.avatarDefaultBig)
    
    /// 姓名
    lazy var nameLabel: UILabel = UILabel(title: "王老五",fontSize: 9)
    
    /// 时间标签
    var viewModel: UserViewModel? {
        didSet {
            // 姓名
            guard var user = viewModel?.user.user else {
                return
            }
            if user.count > 6 {
                user = String(user.prefix(3))+"..."
            }
            nameLabel.text = user
            nameLabel.textColor = .red
            // 头像
            iconView.kf.setImage(with: viewModel?.userProfileUrl, placeholder: viewModel?.userDefaultIconView, options: [.forceRefresh])
            iconView.isUserInteractionEnabled = true
            iconView.layer.cornerRadius = 5
            iconView.layer.masksToBounds = true
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UserCollectionView {
    private func setupUI() {
        addSubview(iconView)
        addSubview(nameLabel)
        nameLabel.lineBreakMode = .byTruncatingTail
        iconView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(UserCollectionCellMargin)
            make.left.equalTo(self.snp.left).offset(UserCollectionCellMargin)
            make.width.equalTo(UserCollectionCellIconWidth)
            make.height.equalTo(UserCollectionCellIconWidth)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom)
            make.centerX.equalTo(iconView.snp.centerX)
        }
    }
}
