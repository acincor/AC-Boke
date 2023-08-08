//
//  LiveCellTopView.swift
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
    private lazy var nameLabel: UILabel = UILabel(title: "王老五", fontSize: 14)
    
    /// 时间标签
    private lazy var timeLabel: UILabel = UILabel(title: "现在", fontSize: 11, color: UIColor.red)
    
    /// 可更改来源标签
    lazy var sourceLabel: UILabel = UILabel(title: "直播中...", fontSize: 11)
    var viewModel: FriendViewModel? {
        didSet {
            // 姓名
            nameLabel.text = viewModel?.friend.user
            nameLabel.textColor = .red
            // 头像
            iconView.sd_setImage(with: viewModel?.friendProfileUrl, placeholderImage: viewModel?.friendDefaultIconView)
            iconView.isUserInteractionEnabled = true
            iconView.layer.cornerRadius = 15
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
        let sepView = UIView()
        sepView.backgroundColor = UIColor.lightGray
        addSubview(sepView)
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        sourceLabel.textColor = .white
        iconView.snp.makeConstraints { make in
            make.top.equalTo(sepView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(self.snp.left).offset(StatusCellMargin)
            make.width.equalTo(StatusCellIconWidth)
            make.height.equalTo(StatusCellIconWidth)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.top)
            make.left.equalTo(iconView.snp.right).offset(StatusCellMargin)
        }
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconView.snp.bottom)
            make.left.equalTo(iconView.snp.right).offset(StatusCellMargin)
        }
        sourceLabel.snp.makeConstraints { make in
            make.bottom.equalTo(timeLabel.snp.bottom)
            make.left.equalTo(timeLabel.snp.right).offset(StatusCellMargin)
        }
        sepView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(StatusCellMargin)
        }
    }
}
