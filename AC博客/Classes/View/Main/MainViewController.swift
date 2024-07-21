//
//  MainViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit

import WebKit
import SwiftUI
class MainViewController: UITabBarController {
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    override func viewDidLoad() {
        super.viewDidLoad()
        addChilds()
        // Do any additional setup after loading the view.
        /*
        NetworkTools.shared.request(NetworkTools.HMRequestMethod.POST,"http://httpbin.org/post", ["name":"zhangsan","age":18]) {
            (Result,Error) -> () in
        }
         */
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension MainViewController {
    
    private func addChilds() {
        tabBar.tintColor = UIColor.red
        addChild(HomeTableViewController(), NSLocalizedString("首页", comment: ""), "tabbar_home")
        addChild(MessageTableViewController(), NSLocalizedString("消息", comment: ""), "tabbar_message_center")
        addChild(DiscoverTableViewController(), NSLocalizedString("发现", comment: ""), "tabbar_discover")
        if UserAccountViewModel.sharedUserAccount.userLogon {
            addChild(UIHostingController(rootView: UserNavigationLinkView(account: nil, uid: UserAccountViewModel.sharedUserAccount.account!.uid!)), NSLocalizedString("我", comment: ""), "tabbar_profile")
            //个人喜欢四个登陆界面相同，若想改成NavigationView的ViewController也可以，只是不美观，因为不同，但是我们是处理好的
        } else {
            addChild(ProfileTableViewController(account: nil), NSLocalizedString("我", comment: ""), "tabbar_profile")
        }
    }
    private func addChild(_ vc: UIViewController,_ title: String, _ imageName: String) {
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
    }
}
