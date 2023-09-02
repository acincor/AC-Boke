//
//  CommentCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

let CommentCommentCellMargin: CGFloat = 12
let CommentCommentCellIconWidth: CGFloat = 35
class CommentCommentCell: StatusCommentCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension CommentCommentCell {
    override func setupUI() {
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(2 * CommentCellMargin + CommentCellIconWidth)
        }
        contentLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topView.snp.bottom).offset(CommentCellMargin)
            make.left.equalTo(contentView.snp.left).offset(CommentCellMargin)
        }
        //pictureView.snp.makeConstraints { (make) -> Void in
            //make.top.equalTo(contentLabel.snp.bottom).offset(CommentCellMargin)
            //make.left.equalTo(contentLabel.snp.left)
            //make.width.equalTo(300)
            //make.height.equalTo(90)
        //}
        bottomView = CommentCommentCellBottomView()
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp.bottom).offset(CommentCellMargin)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(44)
        }
        contentLabel.labelDelegate = self
    }
}
