//
//  UIButton+Extension.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/7.
//

import Foundation
import UIKit
extension UIButton {
    convenience init(imageName:String,backImageName:String?) {
        self.init()
        setImage(UIImage(named: imageName), for: .normal)
        setImage(UIImage(named: imageName+"_highlighted"), for: .highlighted)
        if let backImageName = backImageName {
            setBackgroundImage(UIImage(named: backImageName), for: .normal)
            setBackgroundImage(UIImage(named: backImageName + "_highlighted"), for: .highlighted)
        }
        sizeToFit()
    }
    convenience init(title: String, color: UIColor, backImageName: String?, backColor: UIColor? = nil) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        if let backImageName = backImageName {
            setBackgroundImage(UIImage(named: backImageName), for: .normal)
        }
        sizeToFit()
    }
    convenience init(title: String, fontSize: CGFloat, color: UIColor, imageName: String?, backColor: UIColor? = nil) {
        self.init()
        setTitle(title, for: UIControl.State())
        setTitleColor(color, for: UIControl.State())
        if let imageName = imageName {
            setImage(UIImage(named: imageName), for: UIControl.State())
        }
        backgroundColor = backColor
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        sizeToFit()
    }
    func setValue(value: String,key: String) {
        objc_setAssociatedObject(self, &(associatedKey.value_list), [key:value], objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    func getValue() -> [[String:String]]{
        return objc_getAssociatedObject(self, &(associatedKey.value_list)) as! [[String:String]]
    }
    struct associatedKey {
        static var value_list: [[String:String]] = []
    }
}
