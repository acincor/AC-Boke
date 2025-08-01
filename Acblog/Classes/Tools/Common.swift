//
//  Common.swift
//  AC博客
//
//  Created by AC on 2022/10/4.
//

import Foundation
import Kingfisher
let WBSwitchRootViewControllerNotification = "WBSwitchRootViewControllerNotification"
let WBStatusSelectedPhotoNotification = "WBStatusSelectedPhotoNotification"
let WBStatusSelectedPhotoIndexPathKey = "WBStatusSelectedPhotoIndexPathKey"
let WBStatusSelectedPhotoURLsKey = "WBStatusSelectedPhotoURLsKey"
var rootHost:String {
    return "https://mhcincapi.top"
}
@MainActor var listViewModel = TypeNeedCacheListViewModel()
let queue = DispatchQueue(label: "top.mhcinc.notificationQueue", attributes: .concurrent)
let imageCache = ImageCache(name: "com.ACInc.imageCache")
