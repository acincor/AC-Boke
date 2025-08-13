//
//  HomeWebViewController.swift
//  AC博客
//
//  Created by AC on 2022/12/3.
//

import Foundation
import UIKit
import WebKit
class HomeWebViewController: UIViewController,WKNavigationDelegate {
    private var url: URL
    init(url:URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    private lazy var webView = WKWebView()
    override func loadView() {
        view = webView
        title = "网页"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
