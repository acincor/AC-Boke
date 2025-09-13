//
//  Status.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit
/// 博客、消息模型
class Status: NSObject {
    /// ID
    @objc var id: Int = 0
    /// 图片（仅消息）
    @objc var image: String?
    /// 文本内容
    @objc var status: String?
    /// 消息应发送给的用户的UID（仅消息）
    @objc var to_uid: Int = 0
    /// 消息中点赞、撤回操作对应的键（仅消息）
    @objc var code: String?
    /// 创建的时间
    @objc var create_at: String?
    /// 创建的用户的UID
    @objc var uid: Int = 0
    /// 创建者的用户名
    @objc var user:String?
    /// 创建者的头像
    @objc var portrait: String?
    /// 是否存在图片（消息无）
    @objc var have_pic: Int = 0
    /// 图片的数量（消息无）
    @objc var pic_count: Int = 0
    /// 图片url数组（消息无）
    @objc var pic_urls:[[String:String]] = []
    /// 评论数组
    @objc var comment_list:[[String:Any]]?
    /// 评论数
    @objc var comment_count: Int = 0
    /// 点赞数组
    @objc var like_list:[[String:Any]] = []
    /// 点赞数
    @objc var like_count: Int = 0
    /// 来源设备
    @objc var source: String?
    /// 评论的ID
    @objc var comment_id: Int = 0
    /// 评论的uid
    @objc var comment_uid: Int = 0
    /// 评论文本
    @objc var comment: String?
    /// 是否关注
    @objc var isfollowed: Int = 0
    /// 根据字典转模型
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    /// 防止未定义的键报错
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    /// 转成字典形式
    override var description: String {
        let keys = ["code","user","uid","id","status","create_at", "pic_urls","pic_count","have_pic","portrait","source","comment_list","like_list","comment_count","like_count","comment_id","comment","comment_uid","isfollowed"]
        return dictionaryWithValues(forKeys: keys).description
    }
}
