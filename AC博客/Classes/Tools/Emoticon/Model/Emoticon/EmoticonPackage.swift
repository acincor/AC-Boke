//
//  EmoticonPackage.swift
//  Emoticon
//
//  Created by AC on 2022/11/10.
//

import UIKit

// MARK: - 表情包模型
class EmoticonPackage: NSObject {

    /// 表情包所在路径
    @objc var id: String?
    /// 表情包的名称，显示在 toolbar 中
    /*@objc var group_name: String?*/
    /// 表情数组 - 能够保证在使用的时候，数组已经存在，可以直接追加数据
    @objc lazy var emoticons = [Emoticon]()
    
    init(dict: [String: Any]) {
        super.init()
        
        id = dict["id"] as? String
        /*group_name = dict["group_name_"+Locale.current.language.minimalIdentifier.split(separator: "-")[0]] as? String*/
        // 1. 获得字典的数组
        if let array = dict["emoticons"] as? [[String: Any]] {
            // 2. 遍历数组
            for var d in array {
                // 判断是否有 png 的值
                if let png = d["png"] as? String, let dir = id {
                    d["png"] = dir + "/" + png
                }
                emoticons.append(Emoticon(dict: d))
            }
        }
        appendEmptyEmoticon()
    }
    
    override var description: String {
        let keys = ["id", "emoticons"]
        
        return dictionaryWithValues(forKeys: keys).description
    }
    private func appendEmptyEmoticon() {
        let count = emoticons.count % 20
        if emoticons.count > 0 && count == 0 {
            return
        }
        for _ in count..<20 {
            emoticons.append(Emoticon(isEmpty: true))
        }
    }
}

