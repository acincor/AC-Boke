//
//  UIImageView+Extension.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import Foundation
import UIKit
extension UIImageView {
    convenience init(imageName: String) {
        self.init(image:UIImage(named: imageName))
    }
}
