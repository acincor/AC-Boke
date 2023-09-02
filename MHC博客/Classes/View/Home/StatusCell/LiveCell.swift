//
//  LiveCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


let LiveCellMargin: CGFloat = 12
let LiveCellIconWidth: CGFloat = 35
class LiveCell: UICollectionViewCell {
    var viewModel: UserViewModel? {
        didSet {
            topView.viewModel = viewModel
        }
    }
    lazy var topView: UserCellTopView = UserCellTopView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func rowHeight(_ vm: UserViewModel) -> CGFloat {
        viewModel = vm
        contentView.layoutIfNeeded()
        return topView.bounds.maxY
    }
}
extension LiveCell {
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
