//
//  VisitorTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/7.
//

import UIKit

class VisitorTableViewController: UITableViewController {
    var userLogon = UserAccountViewModel.sharedUserAccount.userLogon
    var visitorView: VisitorView?
    override func loadView() {
        userLogon ? super.loadView() : setupVisitorView()
    }
    private func setupVisitorView() {
        visitorView = VisitorView()
        view = visitorView
        visitorView?.registerButton.addTarget(self, action: #selector(VisitorTableViewController.visitorViewDidRegister), for: .touchUpInside)
        //view.backgroundColor = UIColor.red
        visitorView?.loginButton.addTarget(self, action: #selector(VisitorTableViewController.visitorViewDidLogin), for: .touchUpInside)
    }
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension VisitorTableViewController {
    @objc func visitorViewDidRegister() {
        let vc = OAuthViewController(.注册)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    @objc func visitorViewDidLogin() {
        let vc = OAuthViewController(.登录)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}
