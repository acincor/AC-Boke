//
//  UserCollectionCell.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit


let UserCollectionCellMargin: CGFloat = 12
let UserCollectionCellIconWidth: CGFloat = 35
class UserCollectionCell: UICollectionViewCell {
    var viewModel: UserViewModel? {
        didSet {
            topView.viewModel = viewModel
        }
    }
    lazy var topView: UserCollectionView = UserCollectionView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UserCollectionCell {
    func setupUI() {
        contentView.addSubview(topView)
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(2 * UserCellMargin + UserCellIconWidth)
        }
        //pictureView.snp.makeConstraints { (make) -> Void in
        //make.top.equalTo(contentLabel.snp.bottom).offset(FriendCellMargin)
        //make.left.equalTo(contentLabel.snp.left)
        //make.width.equalTo(300)
        //make.height.equalTo(90)
        //}
    }
}
