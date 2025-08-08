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
extension UIBarButtonItem {
    
    private struct AssociatedKey {
        @MainActor static var vm: StatusViewModel?
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
    func setAssociated<T>(value: T, associatedKey: UnsafeRawPointer, policy: objc_AssociationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> Void {
        objc_setAssociatedObject(self, associatedKey, value, policy)
    }
    
    func getAssociated<T>(associatedKey: UnsafeRawPointer) -> T? {
        let value = objc_getAssociatedObject(self, associatedKey) as? T
        return value;
    }
}
