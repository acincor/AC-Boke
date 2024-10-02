//
//  UIBarButtonItem+Extension.swift
//  AC博客
//
//  Created by AC on 2022/11/11.
//

import Foundation
import UIKit
extension UIBarButtonItem {
    convenience init(imageName: String, target: Any?, actionName: String?) {
        let button = UIButton(imageName: imageName, backImageName: nil)
        if let actionName = actionName {
            button.addTarget(target, action: Selector(actionName), for: .touchUpInside)
        }
        self.init(customView: button)
    }
}
