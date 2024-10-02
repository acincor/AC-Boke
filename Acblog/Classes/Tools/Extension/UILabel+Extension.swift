//
//  UILabel+Extension.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import Foundation
import UIKit
extension UILabel {
    convenience init(title: String, fontSize: CGFloat = 14, color: UIColor = UIColor.darkGray, screenInset: CGFloat = 0) {
        self.init()
        text = title
        textColor = color
        font = UIFont.systemFont(ofSize: fontSize)
        numberOfLines = 0
        if screenInset == 0 {
            textAlignment = .center
        } else {
            preferredMaxLayoutWidth = UIScreen.main.bounds.width - 2 * screenInset
            textAlignment = .left
        }
        sizeToFit()
    }
}
