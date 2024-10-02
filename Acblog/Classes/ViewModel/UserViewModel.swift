//
//  UserViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit
let LiveCellNormalId = "LiveCellNormalId"
let UserCellNormalId = "UserCellNormalId"
/// 微博视图模型 - 处理单条微博的业务逻辑
class UserViewModel: CustomStringConvertible {
    
    /// 微博的模型
    var user: Account
    
    /// 用户头像 URL
    var userProfileUrl: URL {
        return URL(string: user.portrait ?? "")!
    }
    @MainActor lazy var rowHeight: CGFloat = {
        var cell: UserCell
        cell = UserCell(style: .default, reuseIdentifier: UserCellNormalId)
        return cell.rowHeight(self)
    }()
    /// 用户默认头像
    var userDefaultIconView: UIImage {
        return UIImage(named: "avatar_default_big")!
    }
    
    /// 构造函数
    init(user: Account) {
        self.user = user
    }
    
    /// 描述信息
    var description: String {
        return "<FriendViewModel>"
    }
    
}
