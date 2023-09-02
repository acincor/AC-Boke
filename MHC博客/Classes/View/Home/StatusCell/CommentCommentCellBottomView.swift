//
//  StatusCellBottonView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//


import UIKit

// MARK: - 设置界面
import UIKit

// MARK: - 设置界面
class CommentCommentCellBottomView: StatusCellBottomView {
    override func setupUI() {
        // 0. 设置背景颜色
        backgroundColor = .systemBackground
        
        // 1. 添加控件
        addSubview(deleteButton)
        addSubview(likeButton)
        deleteButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        likeButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(deleteButton.snp.top)
            make.left.equalTo(deleteButton.snp.right)
            make.width.equalTo(deleteButton.snp.width)
            make.height.equalTo(deleteButton.snp.height)
            make.right.equalTo(self.snp.right)
        }
        // 3. 分隔视图
        //let sep1 = sepView()
        //addSubview(sep1)
        
        // 布局
        /*
        let w = 1
        let scale = 0.4
        sep1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(deleteButton.snp.right)
            make.centerY.equalTo(deleteButton.snp.centerY)
            make.width.equalTo(w)
            make.height.equalTo(deleteButton.snp.height)
                .multipliedBy(scale)
        }
        */
    }
/// 创建分隔视图
/*
func sepView() -> UIView {
    let v = UIView()
    v.backgroundColor = .systemBackground
    return v
}
*/
}

