//
//  Common.swift
//  AC博客
//
//  Created by AC on 2022/10/4.
//

import Foundation
import Kingfisher
let ACSwitchRootViewControllerNotification = "ACSwitchRootViewControllerNotification"
let ACStatusSelectedPhotoNotification = "ACStatusSelectedPhotoNotification"
let ACStatusSelectedPhotoIndexPathKey = "ACStatusSelectedPhotoIndexPathKey"
let ACStatusSelectedPhotoURLsKey = "ACStatusSelectedPhotoURLsKey"
var rootHost:String {
    return "https://mhcincapi.top"
}
@MainActor var listViewModel = TypeNeedCacheListViewModel()
let imageCache = ImageCache(name: "com.ACInc.imageCache")
enum User: String {
    case SomeBody = "SomeBody"
    case Me = "Me"
}
