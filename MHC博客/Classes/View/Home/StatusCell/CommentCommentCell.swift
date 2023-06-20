//
//  CommentCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

let CommentCommentCellMargin: CGFloat = 12
let CommentCommentCellIconWidth: CGFloat = 35
protocol CommentCommentCellDelegate: NSObjectProtocol {
    func commentCommentCellDidClickUrl(url:URL)
}
class CommentCommentCell: UITableViewCell {
    weak var cellDelegate: CommentCommentCellDelegate?
    var viewModel: CommentCommentViewModel? {
        didSet {
            let text = viewModel?.comment.comment ?? ""
            contentLabel.attributedText = EmoticonManager.sharedManager.emoticonText(string: text, font: contentLabel.font)
            topView.viewModel = viewModel
        }
    }
    private lazy var topView: CommentCommentCellTopView = CommentCommentCellTopView()
    lazy var contentLabel: FFLabel = FFLabel(title: "微博正文", fontSize: 15, color: .darkGray, screenInset: CommentCommentCellMargin)
    lazy var bottomView: CommentCommentCellBottomView = CommentCommentCellBottomView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func rowHeight(_ vm: CommentCommentViewModel) -> CGFloat {
        viewModel = vm
        contentView.layoutIfNeeded()
        return bottomView.frame.maxY
    }
}
extension CommentCommentCell {
    @objc func setupUI() {
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(bottomView)
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(2 * CommentCommentCellMargin + CommentCommentCellIconWidth)
        }
        contentLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topView.snp.bottom).offset(CommentCommentCellMargin)
            make.left.equalTo(contentView.snp.left).offset(CommentCommentCellMargin)
        }
        //pictureView.snp.makeConstraints { (make) -> Void in
            //make.top.equalTo(contentLabel.snp.bottom).offset(CommentCellMargin)
            //make.left.equalTo(contentLabel.snp.left)
            //make.width.equalTo(300)
            //make.height.equalTo(90)
        //}
        bottomView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp.bottom).offset(CommentCommentCellMargin)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(44)
        }
        contentLabel.labelDelegate = self
    }
}
extension CommentCommentCell: FFLabelDelegate {
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        if text.hasPrefix("http://") {
            guard let url = URL(string: text) else {
                return
            }
            cellDelegate?.commentCommentCellDidClickUrl(url: url)
        }
        if text.hasPrefix("https://") {
            guard let url = URL(string: text) else {
                return
            }
            cellDelegate?.commentCommentCellDidClickUrl(url: url)
        }
    }
}
