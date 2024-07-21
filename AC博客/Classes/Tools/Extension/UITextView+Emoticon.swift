//
//  UITextView+Emoticon.swift
//  Emoticon
//
//  Created by AC on 2022/11/10.
//

import Foundation
import UIKit
extension UITextView {
    func insertEmoticon(_ em: Emoticon) {
        
        // 1. 空白表情
        if em.isEmpty {
            return
        }
        
        // 2. 删除按钮
        if em.isRemoved {
            deleteBackward()
            return
        }
        if let emoji = em.emoji {
            replace(selectedTextRange!, withText: emoji)
            return
        }
        insertImageEmoticon(em)
        delegate?.textViewDidChange?(self)
    }
    func insertImageEmoticon(_ em: Emoticon) {
        let imageText = EmoticonAttachment(emoticon: em).imageText(font: font!)
        let strM = NSMutableAttributedString(attributedString: attributedText)
        strM.replaceCharacters(in: selectedRange, with: imageText)
        let range = selectedRange
        attributedText = strM
        selectedRange = NSRange(location: range.location+1, length: 0)
    }
    
    var emoticonText: String {
        let attrString = attributedText
        var strM = String()
        attrString?.enumerateAttributes(in: NSRange(location: 0, length: attrString!.length), options: []) { dict, range, _ in
            if let attachment = dict[.init("NSAttachment")] as? EmoticonAttachment {
                strM += attachment.emoticon.chs ?? ""
            } else {
                let str = (attrString!.string as NSString).substring(with: range)
                strM += str
            }
        }
        return strM
    }
}
