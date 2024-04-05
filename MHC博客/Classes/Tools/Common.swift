//
//  Common.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/10/4.
//

import Foundation
let WBSwitchRootViewControllerNotification = "WBSwitchRootViewControllerNotification"
let WBStatusSelectedPhotoNotification = "WBStatusSelectedPhotoNotification"
let WBStatusSelectedPhotoIndexPathKey = "WBStatusSelectedPhotoIndexPathKey"
let WBStatusSelectedPhotoURLsKey = "WBStatusSelectedPhotoURLsKey"
var rootHost:String {
    return "http://192.168.31.128"
}
var listViewModel = StatusListViewModel()
