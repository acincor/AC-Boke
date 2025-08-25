//
//  Common.swift
//  AC博客
//
//  Created by AC on 2022/10/4.
//

import Foundation
import Kingfisher
import SVProgressHUD
let ACSwitchRootViewControllerNotification = "ACSwitchRootViewControllerNotification"
let ACStatusSelectedPhotoNotification = "ACStatusSelectedPhotoNotification"
let ACStatusSelectedPhotoIndexPathKey = "ACStatusSelectedPhotoIndexPathKey"
let ACStatusSelectedPhotoURLsKey = "ACStatusSelectedPhotoURLsKey"
let localTest = true
var rootHost:String {
    return localTest ? "http://localhost:8080" : "https://mhcincapi.top"
}
//@MainActor var listViewModel = TypeNeedCacheListViewModel()
let imageCache = ImageCache(name: "com.ACInc.imageCache")
func dismissAlert() {
    DispatchQueue.main.asyncAfter(deadline: .now()+1){
        SVProgressHUD.dismiss()
    }
}
func showInfo(_ status: String) {
    Task { @MainActor in
        SVProgressHUD.showInfo(withStatus: NSLocalizedString(status, comment: ""))
    }
    dismissAlert()
}
func showError(_ status: String) {
    Task { @MainActor in
        SVProgressHUD.showError(withStatus: NSLocalizedString(status, comment: ""))
    }
    dismissAlert()
}
func showAlert(_ image: UIImage, _ status: String) {
    Task { @MainActor in
        SVProgressHUD.show(image, status: NSLocalizedString(status, comment: ""))
    }
    dismissAlert()
}

enum User: String {
    case SomeBody = "SomeBody"
    case Me = "Me"
}
