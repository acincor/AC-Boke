//
//  UIImageView+Extension.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import Foundation
import UIKit
extension UIImageView {
    convenience init(imageName: String) {
        self.init(image:UIImage(named: imageName))
    }
}
