//
//  OAuthViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit
import WebKit
import SVProgressHUD
class OAuthViewController: UIViewController,WKNavigationDelegate {
    private lazy var webView = WKWebView()
    @objc private func close() {
        dismiss(animated: true,completion: nil)
    }
    @objc private func closeUserAgreement() {
        controller.dismiss(animated: true,completion: nil)
    }
    let controller = UIViewController()
    @objc private func userAgreement() {
        let textView = UITextView(frame: UIScreen.main.bounds)
        guard let userAgreement = Bundle.main.path(forResource: "用户协议", ofType: "txt") else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("似乎找不到目录", comment: ""))
            return
        }
        do{
            let readStr:NSString=try NSString(contentsOfFile: userAgreement, encoding: String.Encoding.utf8.rawValue)
            textView.text = readStr as String
            textView.isEditable = false
            controller.view = textView
            controller.title = NSLocalizedString("用户协议",comment: "")
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭",comment: ""), style: .plain, target: self, action: #selector(OAuthViewController.closeUserAgreement))
            controller.navigationItem.leftBarButtonItem?.tintColor = .red
            present(UINavigationController(rootViewController: controller), animated: true)
        } catch _ {
        }
    }
    override func viewDidLoad() {
        view.addSubview(webView)
        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.backgroundColor = .systemBackground
        // 关掉自动偏移的设置，因为 view 不可能被遮挡，您就别偏移了。
        if #available(iOS 11.0, *){
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }else{
            automaticallyAdjustsScrollViewInsets = false
        }
        //滚动视图贴着view的四边就OK了，对安全区域的适配通过 tableHeaderView 和 tableFooterView 来处理。
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.load(URLRequest(url: oauthURL!))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭",comment: ""), style: .plain, target: self, action: #selector(OAuthViewController.close))
        navigationItem.leftBarButtonItem?.tintColor = .red
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("用户协议",comment: ""), style: .plain, target: self, action: #selector(OAuthViewController.userAgreement))
        navigationItem.rightBarButtonItem?.tintColor = .red
    }
    enum 登录方式: String {
        case 注册 = "注册"
        case 登录 = "登录"
    }
    init(_ 方式: 登录方式) {
        super.init(nibName: nil, bundle: nil)
        if 方式.rawValue == "注册" {
            oauthURL = URL(string: rootHost+"/api/register.html")
            title = NSLocalizedString("注册Ac博客", comment: "")
            return
        }
        title = NSLocalizedString("登录Ac博客", comment: "")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //默认登录
    var oauthURL = URL(string: rootHost+"/api/login.html")
    
}
extension OAuthViewController {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        guard let url = webView.url, url.host(percentEncoded: false) == "mhcincapi.top" else {
            return .allow
        }
        guard let query = url.query,query.contains("code=") else {
            return .allow
        }
        let code = String(query["code=".endIndex...])
        UserAccountViewModel.sharedUserAccount.loadAccessToken(code: code) { (isSuccessed) -> () in
            if !isSuccessed {
                return
            }
            Task { @MainActor in
                self.dismiss(animated: false) {
                    NotificationCenter.default.post(name: .init(rawValue: WBSwitchRootViewControllerNotification), object: "welcome")
                }
            }
        }
        return .cancel
    }
}
extension OAuthViewController : WKUIDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor() -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        present(alertController, animated: true, completion: nil)
        print("dsf")
    }
}
