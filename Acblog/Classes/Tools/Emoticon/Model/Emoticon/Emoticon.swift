//
//  Emoticon.swift
//  Emoticon
//
//  Created by AC on 2022/11/10.
//

import UIKit

import UIKit

// MARK: - 表情模型
class Emoticon: NSObject {
    /// 次数
    @objc var times = 0
    /// 代表的表情包文字
    @objc var chs: String?
    /// 表情包图片所在位置
    @objc var png: String?
    /// 将code转成emoji
    @objc var emoji: String?
    /// 是否为空
    @objc var isEmpty = false
    init(isEmpty: Bool) {
        self.isEmpty = isEmpty
        super.init()
    }
    /// emoji的code
    @objc var code: String? {
        didSet {
            emoji = code?.emoji
        }
    }
    /// 完整路径
    @objc var imagePath: String {
        // 判断是否有图片
        if png == nil {
            return ""
        }
        // 拼接完整路径
        return Bundle.main.bundlePath + "/Emoticons.bundle/" + png!
    }
    /// 将字典转位模型
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    /// 防止未定义的键报错
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    override var description: String {
        let keys = ["chs", "png", "code"]
        return dictionaryWithValues(forKeys:keys).description
    }
}

