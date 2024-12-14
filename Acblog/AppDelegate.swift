//
//  AppDelegate.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit
import UserNotifications
import SVProgressHUD

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
            DataSaver.set(data: notification.object)
            Task { @MainActor in
                let vc = DataSaver.get() != nil ? WelcomeViewController() : MainViewController()
                self?.window?.rootViewController = vc
            }
        }
        NotificationCenter.default.addObserver(forName: .init("WBSwitchRootViewControllerLogOutNotification"), object: nil, queue: nil) { (notification) in
            let object = notification.object as? String
            Task { @MainActor in
                if UserAccountViewModel.sharedUserAccount.userLogon {
                    if object != nil {
                        NetworkTools.shared.ExpiresTheToken { Result, Error in
                            if (Result as! [String:Any])["msg"] as! Int == 1 {
                                Task{@MainActor in
                                    self.removeFile()
                                }
                            }
                        }
                    } else {
                        NetworkTools.shared.logOff { Result, Error in
                            if (Result as! [String:Any])["msg"] as! Int == 1 {
                                Task{@MainActor in
                                    self.removeFile()
                                }
                            }
                        }
                    }
                    StatusDAL.clearDataCache(type: nil)
                }
            }
        }
        if UserAccountViewModel.sharedUserAccount.userLogon {
            NetworkTools.shared.tokenIsExpires { Result, Error in
                if (Result as? [String:Any])?["msg"] as? Int == 1 {
                    Task{@MainActor in
                        self.removeFile()
                    }
                }
            }
        }
        return true
    }
    func removeFile() {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        path = (path as NSString).appendingPathComponent("account.plist")
        if FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.removeItem(atPath: path)
            UserAccountViewModel.sharedUserAccount.account = nil
            NotificationCenter.default.post(name: .init(rawValue: .init(WBSwitchRootViewControllerNotification)), object: nil)
        }
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
    func applicationDidEnterBackground(_ application: UIApplication) {
        StatusDAL.clearDataCache(type: nil)
        
        if UserAccountViewModel.sharedUserAccount.userLogon {
            let content = UNMutableNotificationContent()
            content.title = "AC博客"
            content.sound = .default
            content.badge = true
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            NetworkTools.shared.loadHotStatus { Result, Error in
                if Result == nil {
                    Task { @MainActor in
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后再试",comment: ""))
                    }
                    return
                }
                if((Result as! [String:Any])["user"] != nil || (Result as! [String:Any])["status"] != nil) {
                    DataSaver.set(data: Result)
                    guard let Result = DataSaver.get() as? [String:Any] else {
                        return
                    }
                    let status = Status(dict: Result)
                    DataSaver.set(data: status)
                }
            }
            guard let status = DataSaver.get() as? Status else {
                return
            }
            content.body = status.status ?? ""
            content.title = status.user!
            content.subtitle = status.create_at!
            let request = UNNotificationRequest(identifier: "com.ACInc.ACBlog", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
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


