//
//  StatusViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit

/// 微博视图模型 - 处理单条微博的业务逻辑
class StatusViewModel: CustomStringConvertible {
    
    /// 微博的模型
    var status: Status
    
    /// 用户头像 URL
    var userProfileUrl: URL {
        let 中文转换过的url = status.portrait?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string: 中文转换过的url ?? "")!
    }
    /// 用户默认头像
    var userDefaultIconView: UIImage {
        return .avatarDefaultBig
    }
    @MainActor var rowHeight: CGFloat {
        if self.status.image != nil {
            return StatusNormalCell(style: .default, reuseIdentifier: chatID).rowHeight(self)
        }
        return StatusNormalCell(style: .default, reuseIdentifier: StatusCellNormalId).rowHeight(self)
    }
    var cellId: String {
        if status.to_uid == 0 {
            return StatusCellNormalId
        }
        return chatID
    }
    //点赞消息
    var attributedStatus: NSMutableAttributedString?
    /// 用户认证图标
    /// 认证类型，-1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    var createAt: String? {
        return Date.sina(status.create_at ?? "")?.dateDescription
    }
    /// 缩略图URL数组 - 存储型属性 !!!
    var thumbnailUrls: [URL]?
    
    /// 构造函数
    init(status: Status) {
        self.status = status
        
        // 根据模型，来生成缩略图的数组
        let urls = status.pic_urls
        // 创建缩略图数组
        thumbnailUrls = [URL]()
        
        // 遍历字典数组 - 数组如果是可选的，不允许遍历，原因：数组是通过下标来检索数据
        if urls.count != 0 {
            for dict in 0 ... urls.count - 1{
                
                // 因为字典是按照 key 来取值，如果 key 错误，会返回 nil
                let url = URL(string: urls[dict]["pic\(dict)"]!)
                
                // 相信服务器返回的 url 字符串一定能够生成
                thumbnailUrls?.append(url!)
            }
        }
    }
    
    /// 描述信息
    var description: String {
        return status.description + "配图数组 \(thumbnailUrls ?? [] as Array)"
    }
    
}
