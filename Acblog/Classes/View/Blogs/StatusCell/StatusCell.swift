//
//  StatusCell.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit
import SwiftUI

let StatusCellMargin: CGFloat = 12
let StatusCellIconWidth: CGFloat = 35
protocol StatusCellDelegate: NSObjectProtocol {
    func statusCellDidClickUrl(url:URL)
    func present(_ controller: UIViewController)
}
class StatusCell: UITableViewCell {
    weak var cellDelegate: StatusCellDelegate?
    lazy var pictureView: StatusPictureView = StatusPictureView()
    var viewModel: StatusViewModel? {
        didSet {
            let text = viewModel?.status.status ?? viewModel?.status.comment ?? ""
            contentLabel.attributedText = viewModel?.attributedStatus ?? EmoticonManager.sharedManager.emoticonText(string: text, font: contentLabel.font)
            topView.viewModel = viewModel
            pictureView.backgroundColor = .systemBackground
            pictureView.viewModel = viewModel
            pictureView.snp.updateConstraints { make in
                make.height.equalTo(pictureView.bounds.height)
                make.width.equalTo(pictureView.bounds.width)
            }
            if viewModel?.cellId == chatID {
                bottomView.commentButton.removeFromSuperview()
                if viewModel!.status.to_uid == Int(UserAccountViewModel.sharedUserAccount.account!.uid!) {
                    bottomView.deleteButton.setTitle(NSLocalizedString("删除", comment: ""), for: .normal)
                    bottomView.likeButton.setTitle(NSLocalizedString("赞", comment: ""), for: .normal)
                    bottomView.likeButton.isHidden = false
                    bottomView.deleteButton.snp.remakeConstraints { (make) -> Void in
                        make.top.equalTo(bottomView.snp.top)
                        make.left.equalTo(bottomView.snp.left)
                        make.bottom.equalTo(bottomView.snp.bottom)
                    }
                    bottomView.likeButton.snp.remakeConstraints { (make) -> Void in
                        make.top.equalTo(bottomView.deleteButton.snp.top)
                        make.left.equalTo(bottomView.deleteButton.snp.right)
                        make.width.equalTo(bottomView.deleteButton.snp.width)
                        make.height.equalTo(bottomView.deleteButton.snp.height)
                        make.right.equalTo(bottomView.snp.right)
                    }
                }else{
                    bottomView.likeButton.isHidden = true
                    bottomView.deleteButton.snp.remakeConstraints { (make) -> Void in
                        make.left.equalTo(bottomView.snp.left)
                        make.top.equalTo(bottomView.snp.top)
                        make.right.equalTo(bottomView.snp.right)
                        make.bottom.equalTo(bottomView.snp.bottom)
                    }
                    bottomView.deleteButton.setTitle(NSLocalizedString("撤回", comment: ""), for: .normal)
                }
            }
        }
    }
    lazy var topView: StatusCellTopView = StatusCellTopView()
    lazy var contentLabel: FFLabel = FFLabel(title: NSLocalizedString("微博正文", comment: ""), fontSize: 15, color: .label, screenInset: StatusCellMargin)
    lazy var bottomView: StatusCellBottomView = StatusCellBottomView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(pictureView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(44)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func rowHeight(_ vm: StatusViewModel) -> CGFloat {
        viewModel = vm
        contentView.layoutIfNeeded()
        if vm.status.code == "recalled" || vm.status.code == "like"{
            return contentLabel.frame.maxY
        }
        return bottomView.frame.maxY
    }
}
extension StatusCell {
    @objc func setupUI() {
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(2 * StatusCellMargin + StatusCellIconWidth)
        }
        contentLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp.left).offset(StatusCellMargin)
        }
        //pictureView.snp.makeConstraints { (make) -> Void in
        //make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
        //make.left.equalTo(contentLabel.snp.left)
        //make.width.equalTo(300)
        //make.height.equalTo(90)
        //}
        
        contentLabel.labelDelegate = self
    }
}

extension StatusCell: @preconcurrency FFLabelDelegate {
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
                guard let res = Result as? [String:Any] else {
                    showError("加载数据错误，请稍后重试")
                    return
                }
                guard res["uid"] is String else {
                    showError("加载数据错误，请稍后重试")
                    return
                }
                self.cellDelegate?.present(UINavigationController(rootViewController: ProfileTableViewController(account: UserViewModel(user: Account(dict: res)))))
            }
        }
    }
}
