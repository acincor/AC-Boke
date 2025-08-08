//
//  UIButton+Extension.swift
//  AC博客
//
//  Created by AC on 2022/9/7.
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
        backgroundColor = backColor
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
}
extension UIButton {
    struct AssociatedKey {
        @MainActor static var vm: StatusViewModel?
    }
    func setAssociated<T>(value: T, associatedKey: UnsafeRawPointer, policy: objc_AssociationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> Void {
        objc_setAssociatedObject(self, associatedKey, value, policy)
    }
    
    func getAssociated<T>(associatedKey: UnsafeRawPointer) -> T? {
        let value = objc_getAssociatedObject(self, associatedKey) as? T
        return value;
    }
    var vm: StatusViewModel? {
        get {
            withUnsafePointer(to: &AssociatedKey.vm) { pointer in
                getAssociated(associatedKey: pointer)
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKey.vm) { pointer in
                setAssociated(value: newValue, associatedKey: pointer)
            }
        }
    }
}
