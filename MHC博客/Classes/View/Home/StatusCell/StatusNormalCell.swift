//
//  StatusNormalCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/10/3.
//

import UIKit

class StatusNormalCell: StatusCell {
    override var viewModel: StatusViewModel? {
        didSet {
            pictureView.snp.updateConstraints { (make) -> Void in
                
                // 根据配图数量，决定配图视图的顶部间距
                let offset = viewModel?.thumbnailUrls?.count == 0 ? 0 : StatusCellMargin
                make.top.equalTo(contentLabel.snp.bottom).offset(offset)
            }
        }
    }
    override func setupUI() {
        super.setupUI()
        pictureView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(contentLabel.snp.left)
            make.width.equalTo(300)
            make.height.equalTo(90)
        }
    }
}
