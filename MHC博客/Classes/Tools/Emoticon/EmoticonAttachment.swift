//
//  EmoticonAttachment.swift
//  Emotion
//
//  Created by mhc team on 2022/11/10.
//

import UIKit

class EmoticonAttachment: NSTextAttachment {
    var emoticon: Emoticon
    init(emoticon: Emoticon) {
        self.emoticon = emoticon
        super.init(data: nil, ofType: nil)
    }
    func imageText(font: UIFont) -> NSAttributedString {
        image = UIImage(contentsOfFile: emoticon.imagePath)
        let lineHeight = font.lineHeight
        bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: self))
        imageText.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: 1))
        return imageText
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
