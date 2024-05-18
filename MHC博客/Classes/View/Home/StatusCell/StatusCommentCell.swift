//
//  StatusCommentCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit
import SwiftUI

let CommentCellMargin: CGFloat = 12
let CommentCellIconWidth: CGFloat = 35
class StatusCommentCell: UITableViewCell, FFLabelDelegate {
    weak var cellDelegate: StatusCommentCellDelegate?
    var viewModel: CommentViewModel? {
        didSet {
            let text = viewModel?.comment.comment ?? ""
            contentLabel.attributedText = EmoticonManager.sharedManager.emoticonText(string: text, font: contentLabel.font)
            topView.viewModel = viewModel
        }
    }
    lazy var topView: StatusCellTopView = StatusCellTopView()
    var bottomView: StatusCellBottomView = StatusCellBottomView()
    lazy var contentLabel: FFLabel = FFLabel(title:NSLocalizedString("微博正文", comment: ""), fontSize: 15, color: .label, screenInset: CommentCellMargin)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func rowHeight(_ vm: CommentViewModel) -> CGFloat {
        viewModel = vm
        contentView.layoutIfNeeded()
        return bottomView.frame.maxY
    }
}
extension StatusCommentCell {
    @objc func setupUI() {
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(bottomView)
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
        bottomView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp.bottom).offset(CommentCellMargin)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(44)
        }
        contentLabel.labelDelegate = self
    }
}
extension StatusCommentCell {
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        if text.hasPrefix("http://") {
            guard let url = URL(string: text) else {
                return
            }
            cellDelegate?.statusCellDidClickUrl(url: url)
        }
        if text.hasPrefix("https://") {
            guard let url = URL(string: text) else {
                return
            }
            cellDelegate?.statusCellDidClickUrl(url: url)
        }
        if text.hasPrefix("@") {
            NetworkTools.shared.loadUserInfo(uid: Int(text.split(separator: "@")[0]) ?? 0) { Result, Error in
                guard let res = Result as? [String:Any], let uid = res["uid"] as? String else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后重试", comment: ""))
                    return
                }
                
                self.cellDelegate?.present(UINavigationController(rootViewController: UIHostingController(rootView: UserNavigationLinkView(account: UserViewModel(user: Account(dict: res)),uid: uid))))
            }
            
        }
    }
}
