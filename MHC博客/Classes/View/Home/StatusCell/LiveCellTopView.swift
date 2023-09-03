//
//  UserCellTopView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


class LiveCellTopView: UIView {
    // MARK: - 懒加载控件
    /// 头像
    private lazy var iconView: UIImageView = UIImageView(imageName: "avatar_default_big")
    
    /// 姓名
    private lazy var nameLabel: UILabel = UILabel(title: "王老五正在直播中",fontSize: 9)
    
    /// 时间标签
    var viewModel: UserViewModel? {
        didSet {
            // 姓名
            guard let user = viewModel?.user.user else {
                return
            }
            var text = user+"直播中..."
            if text.count > 6 {
                text = String(text.prefix(3))+"..."
            }
            nameLabel.text = text
            nameLabel.textColor = .red
            // 头像
            iconView.sd_setImage(with: viewModel?.userProfileUrl, placeholderImage: viewModel?.userDefaultIconView)
            iconView.isUserInteractionEnabled = true
            iconView.layer.cornerRadius = 5
            iconView.layer.masksToBounds = true
        }
    }
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
        fatalError("init(coder:) has not been implemented")
    }
}
extension LiveCellTopView {
    private func setupUI() {
        addSubview(iconView)
        addSubview(nameLabel)
        nameLabel.lineBreakMode = .byTruncatingTail
        iconView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(StatusCellMargin)
            make.left.equalTo(self.snp.left).offset(StatusCellMargin)
            make.width.equalTo(StatusCellIconWidth)
            make.height.equalTo(StatusCellIconWidth)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom)
            make.centerX.equalTo(iconView.snp.centerX)
        }
    }
}
