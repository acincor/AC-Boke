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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension MainViewController {
    
    private func addChilds() {
        tabBar.tintColor = UIColor.red
        addChild(HomeTableViewController(), NSLocalizedString("首页", comment: ""), "tabbar_home")
        addChild(MessageTableViewController(), NSLocalizedString("消息", comment: ""), "tabbar_message_center")
        addChild(DiscoverTableViewController(), NSLocalizedString("发现", comment: ""), "tabbar_discover")
        addChild(ProfileTableViewController(account: nil), NSLocalizedString("我", comment: ""), "tabbar_profile")
    }
    private func addChild(_ vc: UIViewController,_ title: String, _ imageName: String) {
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
    }
}
