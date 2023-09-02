//
//  Comment.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit

class Comment: NSObject {
    @objc var id: Int = 0
    @objc var user: String?
    @objc var comment_id: Int = 0
    @objc var comment_uid: Int = 0
    @objc var comment: String?
    @objc var create_at: String?
    /// 用户头像地址（中图），50×50像素
    @objc var portrait: String?
    @objc var comment_list:[[String:Any]]?
    @objc var comment_count: Int = 0
    @objc var like_list:[[String:Any]] = []
    @objc var like_count: Int = 0
    @objc var source: String?
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    override var description: String {
        let keys = ["user","id","comment_id","comment","create_at","comment_uid","portrait","comment_list","like_list","comment_count","like_count","source"]
        return dictionaryWithValues(forKeys: keys).description
    }
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
}
