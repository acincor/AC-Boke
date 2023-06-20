//
//  AppDelegate.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = defaultRootViewController
        MySearchTextField?.searchBar.resignFirstResponder()
        window?.makeKeyAndVisible()
        NotificationCenter.default.addObserver(
            forName: .init(rawValue: WBSwitchRootViewControllerNotification), // 通知名称，通知中心用来识别通知的
            object: nil,                           // 发送通知的对象，如果为nil，监听任何对象
            queue: nil)                           // nil，主线程
        { [weak self] (notification) -> Void in // weak self，
            let vc = notification.object != nil ? WelcomeViewController() : MainViewController()
            
            // 切换控制器
            self?.window?.rootViewController = vc
        }
        return true
    }
    deinit {
    // 注销通知 - 注销指定的通知
        NotificationCenter.default.removeObserver(self,   // 监听者
                                              name: .init(rawValue: WBSwitchRootViewControllerNotification),           // 监听的通知
                                                  object: nil)                                            // 发送通知的对象
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        StatusDAL.clearDataCache()
        
    }
}
extension AppDelegate {
    
//判断是否为新版本
    private var isNewVersion: Bool {
        // 1. 当前的版本 - info.plist
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Double(currentVersion)!
        // print("当前版本 \(version)")
    
        // 2. `之前`的版本，把当前版本保存在用户偏好 - 如果 key 不存在，返回 0
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = UserDefaults.standard.double(forKey: sandboxVersionKey)
        // print("之前版本 \(sandboxVersion)")
    
        // 3. 保存当前版本
        UserDefaults.standard.set(version, forKey:sandboxVersionKey)
    
        return version > sandboxVersion
}

/// 启动的根视图控制器
    private var defaultRootViewController: UIViewController {
        // 1. 判断是否登录
        if UserAccountViewModel.sharedUserAccount.userLogon {
            return isNewVersion ? NewFeatureViewController() :
                WelcomeViewController()
        }
    
        // 2. 没有登录返回主控制器
        return MainViewController()
    }
}


