//
//  UITapGestureRecognizer+Extension.swift
//  Acblog
//
//  Created by acincor on 2025/8/25.
//
import UIKit
extension UITapGestureRecognizer {
    private struct AssociatedKey {
        @MainActor static var userViewModel: UserViewModel?
    }
    func setAssociated<T>(value: T, associatedKey: UnsafeRawPointer, policy: objc_AssociationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> Void {
        objc_setAssociatedObject(self, associatedKey, value, policy)
    }
    
    func getAssociated<T>(associatedKey: UnsafeRawPointer) -> T? {
        let value = objc_getAssociatedObject(self, associatedKey) as? T
        return value;
    }
    var userViewModel: UserViewModel? {
        get {
            withUnsafePointer(to: &AssociatedKey.userViewModel) { pointer in
                getAssociated(associatedKey: pointer)
            }
        }
        
        set {
            withUnsafePointer(to: &AssociatedKey.userViewModel) { pointer in
                setAssociated(value: newValue,associatedKey: pointer)
            }
        }
    }
}
