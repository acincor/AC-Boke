//
//  MainViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

import WebKit
import SwiftUI
class MainViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        addChilds()
        // Do any additional setup after loading the view.
        setupComposedButton()
        /*
        NetworkTools.shared.request(NetworkTools.HMRequestMethod.POST,"http://httpbin.org/post", ["name":"zhangsan","age":18]) {
            (Result,Error) -> () in
        }
         */
    }
    private lazy var composedButton: UIButton = UIButton(imageName: "tabbar_compose_icon_add", backImageName: "tabbar_compose_button")
    private func setupComposedButton() {
        tabBar.addSubview(composedButton)
        let count = children.count
        let w = tabBar.bounds.width / CGFloat(count) - 1
        composedButton.frame = tabBar.bounds.insetBy(dx: 2 * w, dy: 0)
        composedButton.layer.masksToBounds = true
        composedButton.layer.cornerRadius = 5
        composedButton.addTarget(self, action: #selector(MainViewController.clickComposedButton), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.bringSubviewToFront(composedButton)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc private func clickComposedButton() {
        var vc: UIViewController
        if UserAccountViewModel.sharedUserAccount.userLogon {
            vc = ComposeViewController()
        } else {
            vc = OAuthViewController(.登录)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
extension MainViewController {
    
    private func addChilds() {
        tabBar.tintColor = UIColor.red
        addChild(HomeTableViewController(), "首页", "tabbar_home")
        addChild(MessageTableViewController(), "消息", "tabbar_message_center")
        addChild(UIViewController())
        addChild(DiscoverTableViewController(), "发现", "tabbar_discover")
        if UserAccountViewModel.sharedUserAccount.userLogon {
            addChild(UIHostingController(rootView: NavigationLinkView()), "我", "tabbar_profile")
            //个人喜欢四个登陆界面相同，若想改成NavigationView的ViewController也可以，只是不美观，因为不同，但是我们是处理好的
        } else {
            addChild(ProfileTableViewController(), "我", "tabbar_profile")
        }
    }
    private func addChild(_ vc: UIViewController,_ title: String, _ imageName: String) {
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
    }
}
