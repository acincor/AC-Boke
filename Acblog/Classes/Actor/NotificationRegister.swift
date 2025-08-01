//
//  Data.swift
//  Acblog
//
//  Created by Monkey hammer on 10/2/24.
//
import Foundation
import UIKit
actor NotificationRegister {
    func register(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard self != nil else { return }  // 避免循环引用
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
}
