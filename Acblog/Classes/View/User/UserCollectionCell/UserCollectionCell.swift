//
//  UserCollectionCell.swift
//  Acblog
//
//  Created by acincor on 2025/9/14.
//

import UIKit

class UserCollectionCell: UICollectionViewCell {
    lazy var topView = StatusCellTopView()
    var uvm: UserViewModel? {
        didSet {
            topView.uvm = uvm
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        self.backgroundColor = .systemFill
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.contentView.addSubview(topView)
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.height.equalTo(2 * StatusCellMargin + StatusCellIconWidth)
        }
    }
}
