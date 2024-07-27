//
//  AppDelegate.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground
        SVProgressHUD.setDefaultMaskType(.clear)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if (!granted) {
                       }
        }
        UIApplication.shared.registerForRemoteNotifications()
        MySearchTextField?.searchBar.resignFirstResponder()
        
        window?.rootViewController = defaultRootViewController
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
        NotificationCenter.default.addObserver(forName: .init("WBSwitchRootViewControllerLogOutNotification"), object: nil, queue: nil) { (notification) in
            if notification.object != nil {
                if UserAccountViewModel.sharedUserAccount.userLogon {
                    NetworkTools.shared.ExpiresTheToken { Result, Error in
                        if (Result as! [String:Any])["msg"] as! Int == 1 {
                            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
                            path = (path as NSString).appendingPathComponent("account.plist")
                            if FileManager.default.fileExists(atPath: path) {
                                try! FileManager.default.removeItem(atPath: path)
                                NotificationCenter.default.post(name: .init(rawValue: .init(WBSwitchRootViewControllerNotification)), object: nil)
                            }
                        }
                    }
                }
            } else {
                if UserAccountViewModel.sharedUserAccount.userLogon {
                    NetworkTools.shared.logOff { Result, Error in
                        if (Result as! [String:Any])["msg"] as! Int == 1 {
                            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
                            path = (path as NSString).appendingPathComponent("account.plist")
                            if FileManager.default.fileExists(atPath: path) {
                                try! FileManager.default.removeItem(atPath: path)
                                StatusDAL.clearDataCache(type: nil)
                                NotificationCenter.default.post(name: .init(rawValue: .init(WBSwitchRootViewControllerNotification)), object: nil)
                            }
                        }
                    }
                }
            }
        }
        if UserAccountViewModel.sharedUserAccount.userLogon {
            NetworkTools.shared.tokenIsExpires { Result, Error in
                if (Result as? [String:Any])?["msg"] as? Int == 1 {
                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
                    path = (path as NSString).appendingPathComponent("account.plist")
                    if FileManager.default.fileExists(atPath: path) {
                        try! FileManager.default.removeItem(atPath: path)
                        NotificationCenter.default.post(name: .init(rawValue: .init(WBSwitchRootViewControllerNotification)), object: nil)
                    }
                }
            }
        }
        return true
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
       //Parsing userinfo:
       if let info = userInfo["aps"] as? Dictionary<String, Any>
                {
           print(info["alert"] as! String)
                }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    deinit {
    // 注销通知 - 注销指定的通知
        NotificationCenter.default.removeObserver(self,   // 监听者
                                              name: .init(rawValue: WBSwitchRootViewControllerNotification),           // 监听的通知
                                                  object: nil)
    }
    let content = UNMutableNotificationContent()
    func applicationDidEnterBackground(_ application: UIApplication) {
        StatusDAL.clearDataCache(type: nil)
        if UserAccountViewModel.sharedUserAccount.userLogon {
            content.title = "AC博客"
            content.sound = .default
            
            content.sound = UNNotificationSound.default
            NetworkTools.shared.loadHotStatus { Result, Error in
                if Result == nil {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后再试",comment: ""))
                    return
                }
                if((Result as! [String:Any])["user"] != nil || (Result as! [String:Any])["status"] != nil) {
                    StatusDAL.clearDataCache(type: nil)
                    self.content.badge = true
                    StatusDAL.clearDataCache(type: nil)
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: "com.Ac-inc.ACBlog", content: self.content, trigger: trigger)
                    let status = Status(dict: Result as! [String:Any])
                    self.content.body = status.status
                    self.content.title = status.user!
                    self.content.subtitle = status.create_at!
                    UNUserNotificationCenter.current().add(request) { error in
                        if error != nil {
                            // 处理发送通知时出现的错误
                        } else {
                            // 通知已发送到设备
                        }
                    }
                }
            }
        }
    }
}
extension AppDelegate {
    
//判断是否为新版本
    private var isNewVersion: Bool {
        // 1. 当前的版本 - info.plist
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Double(currentVersion)!
    
        // 2. `之前`的版本，把当前版本保存在用户偏好 - 如果 key 不存在，返回 0
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = UserDefaults.standard.double(forKey: sandboxVersionKey)
    
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


