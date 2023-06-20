//
//  Status.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit

class Status: NSObject {
    @objc var id: Int = 0
    @objc var status: String?
    @objc var create_at: String?
    /// 用户昵称
    /// 用户头像地址（中图），50×50像素
    @objc var uid: Int = 0
    @objc var user:String?
    @objc var portrait: String?
    @objc var have_pic: Int = 0
    @objc var pic_count: Int = 0
    @objc var pic_urls:[[String:String]] = []
    @objc var comment_list:[[String:Any]] = []
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
        let keys = ["user","uid","id","status","create_at", "pic_urls","pic_count","have_pic","portrait","source","comment_list","like_list","comment_count","like_count"]
        return dictionaryWithValues(forKeys: keys).description
    }
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
}
