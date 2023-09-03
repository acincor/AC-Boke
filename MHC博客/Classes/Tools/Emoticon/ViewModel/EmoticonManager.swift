//
//  EmoticonManager.swift
//  Emoticon
//
//  Created by mhc team on 2022/11/10.
//

import UIKit

class EmoticonManager {
    lazy var packages = [EmoticonPackage]()
    static let sharedManager = EmoticonManager()
    func emoticonText(string: String, font: UIFont) -> NSAttributedString {
        
        let strM = NSMutableAttributedString(string: string)
        
        // 1. 正则表达式: [] 是正则表达式的关键字，需要转义
        let pattern = "\\[.*?\\]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        // 2. 匹配多项内容
        let results = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        // 3. 得到匹配的数量
        var count = results.count
        
        // 4. 倒着遍历查找到的范围
        while count > 0 {
            count -= 1
            let range = results[count].range(at: 0)
            
            // 1> 从字符串中获取表情子串
            let emStr = (string as NSString).substring(with: range)
            
            // 2> 根据 emStr 查找对应的表情模型
            if let em = emoticon(string: emStr) {
                
                // 3> 根据 em 建立一个图片属性文本
                let attrText = EmoticonAttachment(emoticon: em).imageText(font: font)
                
                // 4> 替换属性字符串中的内容
                strM.replaceCharacters(in: range, with: attrText)
            }
        }
        
        return strM
    }
    func addFavorite(_ em: Emoticon) {
        em.times += 1
        if !packages[0].emoticons.contains(em) {
            packages[0].emoticons.insert(em, at: 0)
            packages[0].emoticons.remove(at: packages[0].emoticons.count-2)
        }
        packages[0].emoticons.sort { $0.times > $1.times }
    }
    init() {
        packages.append(EmoticonPackage(dict: ["group_name_cn":"最近"]))
        guard let path = Bundle.main.path(forResource: "emoticons", ofType: "plist", inDirectory: "Emoticons.bundle") else {
            return
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return
        }
        let array = (dict["packages"] as! NSArray).value(forKey: "id") as! [String]
        for id in array {
            loadInfoPlist(id)
        }
    }
    private func loadInfoPlist(_ id: String) {
        let path = Bundle.main.path(forResource: "emoticon", ofType: "plist", inDirectory: "Emoticons.bundle/\(id)")!
        let dict = NSDictionary(contentsOfFile: path) as! [String: Any]
        packages.append(EmoticonPackage(dict: dict))
    }
    func emoticon(string: String) -> Emoticon? {
        for package in packages {
            if let emoticon = package.emoticons.filter({ $0.chs == string }).last {
                return emoticon
            }
        }
        return nil
    }
}
