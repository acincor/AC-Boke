//
//  StatusViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

/// 微博视图模型 - 处理单条微博的业务逻辑
class FriendViewModel: CustomStringConvertible {
    
    /// 微博的模型
    var friend: FriendAccount
    
    /// 用户头像 URL
    var friendProfileUrl: URL {
        return URL(string: friend.portrait ?? "")!
    }
    lazy var rowHeight: CGFloat = {
        var cell: FriendCell
        cell = FriendCell(style: .default, reuseIdentifier: FriendCellNormalId)
        return cell.rowHeight(self)
    }()
    /// 用户默认头像
    var friendDefaultIconView: UIImage {
        return UIImage(named: "avatar_default_big")!
    }
    var cellId: String {
        return StatusCellNormalId
    }
    /// 缩略图URL数组 - 存储型属性 !!!
    var thumbnailUrls: [URL]?
    
    /// 构造函数
    init(friend: FriendAccount) {
        self.friend = friend
    }
    
    /// 描述信息
    var description: String {
        return "<FriendViewModel>"
    }
    
}
