//
//  FriendCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


let FriendCellMargin: CGFloat = 12
let FriendCellIconWidth: CGFloat = 35
protocol FriendCellDelegate: NSObjectProtocol {
    func statusCellDidClickUrl(url:URL)
}
class FriendCell: UITableViewCell {
    weak var cellDelegate: FriendCellDelegate?
    var viewModel: FriendViewModel? {
        didSet {
            topView.viewModel = viewModel
        }
    }
    private lazy var topView: FriendCellTopView = FriendCellTopView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func rowHeight(_ vm: FriendViewModel) -> CGFloat {
        viewModel = vm
        contentView.layoutIfNeeded()
        return topView.bounds.maxY
    }
}
extension FriendCell {
    @objc func setupUI() {
        contentView.addSubview(topView)
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(2 * FriendCellMargin + FriendCellIconWidth)
        }
        //pictureView.snp.makeConstraints { (make) -> Void in
            //make.top.equalTo(contentLabel.snp.bottom).offset(FriendCellMargin)
            //make.left.equalTo(contentLabel.snp.left)
            //make.width.equalTo(300)
            //make.height.equalTo(90)
        //}
    }
}
