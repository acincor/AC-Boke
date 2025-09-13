//
//  Account.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit

/// 用户账户模型
class Account: NSObject, NSCoding {
    /// 当前授权用户的UID
    @objc var uid: Int = 0
    /// 当前授权用户的名字
    @objc var user: String?
    /// 用户头像的urlString
    @objc var portrait: String?
    /// 是否关注
    @objc var isfollowed: Int = 0
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    override var description: String {
        let keys = ["uid","user","portrait","isfollowed"]
        return dictionaryWithValues(forKeys: keys).description
    }
    
    // MARK: - `键值`归档和解档
    /// 归档 - 在把当前对象保存到磁盘前，将对象编码成二进制数据
    ///
    /// - parameter coder: 编码器
    func encode(with coder: NSCoder) {
        coder.encode(uid, forKey: "uid")
        coder.encode(user, forKey: "user")
        coder.encode(portrait, forKey: "portrait")
        coder.encode(isfollowed, forKey: "isfollowed")
    }
    
    ///解档 - 从磁盘加载二进制文件，转换成对象时调用
    /// - parameter coder: 解码器
    ///
    /// - returns: 当前对象
    required init?(coder: NSCoder) {
        uid = coder.decodeObject(forKey: "uid") as! Int
        user = coder.decodeObject(forKey: "user") as? String
        portrait = coder.decodeObject(forKey: "portrait") as? String
        isfollowed = coder.decodeObject(forKey: "isfollowed") as! Int
    }
}
