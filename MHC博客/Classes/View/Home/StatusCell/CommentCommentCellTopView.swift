//
//  StatusCellTopView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

class CommentCommentCellTopView: UIView {
    // MARK: - 懒加载控件
    /// 头像
    private lazy var iconView: UIImageView = UIImageView(imageName: "avatar_default_big")
    
    /// 姓名
    private lazy var nameLabel: UILabel = UILabel(title: "王老五", fontSize: 14)
    private lazy var timeLabel: UILabel = UILabel(title: "现在", fontSize: 11, color: UIColor.red)
    var viewModel: CommentCommentViewModel? {
        didSet {
            // 姓名
            timeLabel.text = viewModel?.createAt
            self.nameLabel.text = viewModel?.comment.user
            nameLabel.textColor = .red
            // 头像
            iconView.sd_setImage(with: viewModel?.userProfileUrl, placeholderImage: viewModel?.userDefaultIconView)
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
extension CommentCommentCellTopView {
    private func setupUI() {
        let sepView = UIView()
        sepView.backgroundColor = UIColor.lightGray
        addSubview(sepView)
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(timeLabel)
        iconView.snp.makeConstraints { make in
            make.top.equalTo(sepView.snp.bottom).offset(CommentCellMargin)
            make.left.equalTo(self.snp.left).offset(CommentCellMargin)
            make.width.equalTo(CommentCellIconWidth)
            make.height.equalTo(CommentCellIconWidth)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.top)
            make.left.equalTo(iconView.snp.right).offset(CommentCellMargin)
        }
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconView.snp.bottom)
            make.left.equalTo(iconView.snp.right).offset(CommentCellMargin)
        }
        sepView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(CommentCellMargin)
        }
    }
}
