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
    @objc var times = 0
    @objc var chs: String?
    @objc var png: String?
    @objc var emoji: String?
    @objc var isEmpty = false
    init(isEmpty: Bool) {
        self.isEmpty = isEmpty
        super.init()
    }
    @objc var code: String? {
        didSet {
            emoji = code?.emoji
        }
    }
    @objc var imagePath: String {
        
        // 判断是否有图片
        if png == nil {
            return ""
        }
        // 拼接完整路径
        return Bundle.main.bundlePath + "/Emoticons.bundle/" + png!
    }
    
    init(dict: [String: Any]) {
        super.init()
        
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    override var description: String {
        let keys = ["chs", "png", "code"]
        
        return dictionaryWithValues(forKeys:keys).description
    }
}

