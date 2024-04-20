//
//  logOutViewController.swift
//  MHC博客
//
//  Created by mhc team on 2023/8/27.
//

import Foundation
import UIKit
import SwiftUI
class MyView: UIView{
    @Binding var showing : Bool
    init(showing : Binding<Bool>) {
        _showing = showing
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class logOffController: UIViewController {
    @Binding var showing : Bool
    init(showing : Binding<Bool>) {
        _showing = showing
        super.init(nibName: nil, bundle: nil)
    }
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        view = MyView(showing: $showing)
    }
    override func viewDidAppear(_ animate: Bool) {
        super.viewDidAppear(animate)
        let controller = UIAlertController(title: "注销账号", message: "确定注销账号，不陪我一起玩了吗？", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "注销账号", style: .default) {
            _ in
            NotificationCenter.default.post(name: .init(rawValue: .init("WBSwitchRootViewControllerLogOutNotification")), object: nil)
            UserAccountViewModel.sharedUserAccount.account = nil
        })
        controller.addAction(UIAlertAction(title: "取消", style: .cancel) {
            _ in
            self.showing = false
        })
        self.present(controller, animated: true)
    }
}
class logOutController: UIViewController {
    @Binding var showing : Bool
    init(showing : Binding<Bool>) {
        _showing = showing
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        view = MyView(showing: $showing)
    }
    override func viewDidAppear(_ animate: Bool) {
        super.viewDidAppear(animate)
        let controller = UIAlertController(title: "退出登录", message: "确定要退出登录吗", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "退出登录", style: .default, handler: { n in
            NotificationCenter.default.post(name: .init(rawValue: .init("WBSwitchRootViewControllerLogOutNotification")), object: "logOut")
            UserAccountViewModel.sharedUserAccount.account = nil
        }))
        controller.addAction(UIAlertAction(title: "取消", style: .cancel) {
            _ in
            self.showing = false
        })
        self.present(controller, animated: true)
    }
}
