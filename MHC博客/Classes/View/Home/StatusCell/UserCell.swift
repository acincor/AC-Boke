//
//  UserCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


let UserCellMargin: CGFloat = 12
let UserCellIconWidth: CGFloat = 35
protocol UserCellDelegate: NSObjectProtocol {
    func statusCellDidClickUrl(url:URL)
}
class UserCell: UITableViewCell {
    weak var cellDelegate: UserCellDelegate?
    var viewModel: UserViewModel? {
        didSet {
            topView.viewModel = viewModel
        }
    }
    private lazy var topView: UserCellTopView = UserCellTopView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
extension UserCell {
    @objc func setupUI() {
        contentView.addSubview(topView)
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(2 * UserCellMargin + UserCellIconWidth)
        }
        //pictureView.snp.makeConstraints { (make) -> Void in
            //make.top.equalTo(contentLabel.snp.bottom).offset(UserCellMargin)
            //make.left.equalTo(contentLabel.snp.left)
            //make.width.equalTo(300)
            //make.height.equalTo(90)
        //}
    }
}
