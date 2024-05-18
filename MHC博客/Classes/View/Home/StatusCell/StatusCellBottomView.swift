//
//  StatusCellBottonView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//


import UIKit
class StatusCellBottomView: UIView {
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    func deleteBlog(_ id: Int, finished: @escaping NetworkTools.HMRequstCallBack) {
        NetworkTools.shared.deleteStatus(id, finished: finished)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    /// 评论按钮
    lazy var deleteButton: UIButton = UIButton(title: NSLocalizedString(" 删除",comment: ""), fontSize: 12, color: UIColor(white: 0.6, alpha: 1.0), imageName:
    "timeline_icon_retweet")
    lazy var commentButton: UIButton = UIButton(title: " 评论", fontSize: 12, color: UIColor(white: 0.6, alpha: 1.0), imageName: "timeline_icon_comment")
    
    /// 点赞按钮
    lazy var likeButton: UIButton = UIButton(title: " 赞", fontSize: 12, color: UIColor(white: 0.6, alpha: 1.0), imageName: "timeline_icon_unlike")
}

// MARK: - 设置界面
extension StatusCellBottomView {
    @objc func setupUI() {
        // 0. 设置背景颜色
        backgroundColor = .systemBackground
        
        // 1. 添加控件
        addSubview(deleteButton)
        addSubview(commentButton)
        addSubview(likeButton)
        deleteButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.bottom.equalTo(self.snp.bottom)
        }
        commentButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(deleteButton.snp.top)
            make.left.equalTo(deleteButton.snp.right)
            make.width.equalTo(deleteButton.snp.width)
            make.height.equalTo(deleteButton.snp.height)
        }
        
        likeButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(commentButton.snp.top)
            make.left.equalTo(commentButton.snp.right)
            make.width.equalTo(commentButton.snp.width)
            make.height.equalTo(commentButton.snp.height)
            make.right.equalTo(self.snp.right)
        }
        // 3. 分隔视图
        /*
        let sep1 = sepView()
        let sep2 = sepView()
        addSubview(sep1)
        addSubview(sep2)
        
        // 布局
        let w = 1
        let scale = 0.4
        sep1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(commentButton.snp.right)
            make.centerY.equalTo(commentButton.snp.centerY)
            make.width.equalTo(w)
            make.height.equalTo(commentButton.snp.height)
                .multipliedBy(scale)
        }
        
        sep2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(deleteButton.snp.right)
            make.centerY.equalTo(deleteButton.snp.centerY)
            make.width.equalTo(w)
            make.height.equalTo(deleteButton.snp.height)
                .multipliedBy(scale)
        }
        */
    }
/// 创建分隔视图
func sepView() -> UIView {
    let v = UIView()
    v.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    return v
}
}

