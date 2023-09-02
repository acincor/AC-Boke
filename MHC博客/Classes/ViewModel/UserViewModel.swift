//
//  StatusViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit
let LiveCellNormalId = "LiveCellNormalId"
/// 微博视图模型 - 处理单条微博的业务逻辑
class UserViewModel: CustomStringConvertible {
    
    /// 微博的模型
    var user: Account
    
    /// 用户头像 URL
    var userProfileUrl: URL {
        return URL(string: user.portrait ?? "")!
    }
    lazy var rowHeight: CGFloat = {
        var cell: UserCell
        cell = UserCell(style: .default, reuseIdentifier: UserCellNormalId)
        return cell.rowHeight(self)
    }()
    lazy var rowHeightForLive: CGFloat = {
        var cell: UserCell
        cell = UserCell(style: .default, reuseIdentifier: LiveCellNormalId)
        return cell.rowHeight(self)
    }()
    /// 用户默认头像
    var userDefaultIconView: UIImage {
        return UIImage(named: "avatar_default_big")!
    }
    var cellId: String {
        return UserCellNormalId
    }
    /// 缩略图URL数组 - 存储型属性 !!!
    var thumbnailUrls: [URL]?
    
    /// 构造函数
    init(user: Account) {
        self.user = user
    }
    
    /// 描述信息
    var description: String {
        return "<FriendViewModel>"
    }
    
}
