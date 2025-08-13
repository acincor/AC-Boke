//
//  UserNavigationLinkView.swift
//  Acblog
//
//  Created by acincor on 2025/8/13.
//
import SwiftUI
import Kingfisher
struct UserNavigationLinkView: View {
    @State private var isShowLogoff = false
    @State private var isShowLogout = false
    
    var account: UserViewModel?
    let uid: String
    
    private var name: String {
        account == nil ?
            NSLocalizedString("我的博客", comment: "") :
            NSLocalizedString("TA的博客", comment: "")
    }
    
    private var currentUserID: String {
        if let account = account {
            return "\(account.user.uid)"
        }
        return UserAccountViewModel.sharedUserAccount.account?.uid ?? ""
    }
    
    private var navTitle: String {
        let userName = account?.user.user ?? UserAccountViewModel.sharedUserAccount.account?.user ?? ""
        return "Name: \(userName)"
    }
    
    private func makeController(for type: Clas) -> TypeStatusTableViewController {
        TypeStatusTableViewController(uid: currentUserID, clas: type)
    }
    
    // 公共列表内容
    private var listContent: some View {
        Group {
            ImageDetailView(account: account)
            
            navigationLink(NSLocalizedString("用户协议", comment: ""), destination: MyDetailView(controller: UserAgreementViewController()))
            navigationLink(NSLocalizedString("主页", comment: ""), destination: MyDetailView(controller: ProfileTableViewController(account: account)))
            navigationLink(name, destination: MyDetailView(controller: makeController(for: .blog)))
            navigationLink(NSLocalizedString("点赞过的", comment: ""), image: "timeline_icon_like", destination: MyDetailView(controller: makeController(for: .like)))
            navigationLink(NSLocalizedString("评论过的", comment: ""), image: "timeline_icon_comment", destination: MyDetailView(controller: makeController(for: .comment)))
            
            if account == nil {
                navigationLink("开始直播", image: "live_small_icon", destination: MyDetailView(controller: BKLiveController()))
                
                actionButton("注销账号", action: { isShowLogoff = true })
                actionButton("退出登录", action: { isShowLogout = true })
            }
        }
    }
    
    // 辅助函数
    private func navigationLink(_ title: String, image: String? = nil, destination: some View) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                if let imageName = image {
                    Image(imageName)
                }
                Text(title)
            }
            .foregroundColor(.orange)
        }
    }
    
    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.orange)
        }
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NavigationStack {
                List { listContent }
                    .navigationDestination(isPresented: $isShowLogoff) {
                        MyDetailView(controller: UINavigationController(
                            rootViewController: logOffController(showing: $isShowLogoff)
                        ))
                    }
                    .navigationDestination(isPresented: $isShowLogout) {
                        MyDetailView(controller: UINavigationController(
                            rootViewController: logOutController(showing: $isShowLogout)
                        ))
                    }
            }
            .refreshable {
                makeController(for: .comment).loadData()
                makeController(for: .like).loadData()
            }
            .navigationBarTitle(navTitle)
            .accentColor(.orange)
        } else {
            NavigationView {
                List { listContent }
                    .navigationBarTitle(navTitle)
                    .accentColor(.orange)
            }
        }
    }
}
struct MyDetailView: UIViewControllerRepresentable {
    var controller: UIViewController
    func makeUIViewController(context: Context) -> UIViewController {
        // 返回你想展示的 UIViewController 实例
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 如果需要更新 UIViewController 的状态，可以在这里实现
    }
}

struct ImageDetailView: UIViewRepresentable {
    var account: UserViewModel?
    func makeUIView(context: Context) -> UIView {
        //let view = ProfilePictureView(viewModel: account.portraitUrl)
        let view = UIView()
        let imageView = UIImageView()
        var label: UILabel
        var AIDLabel: UILabel
        if let account = account {
            imageView.kf.setImage(with: account.userProfileUrl, placeholder: nil, options: [.retryStrategy(DelayRetryStrategy(maxRetryCount: 12, retryInterval: .seconds(1))),.fromMemoryCacheOrRefresh])
            label = UILabel(title: "\(account.user.user ?? "")")
            AIDLabel = UILabel(title:"AID: "+"\(account.user.uid)")
        } else {
            imageView.kf.setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl, placeholder: nil, options: [.retryStrategy(DelayRetryStrategy(maxRetryCount: 12, retryInterval: .seconds(1))),.fromMemoryCacheOrRefresh])
            label = UILabel(title: UserAccountViewModel.sharedUserAccount.account?.user ?? "")
            AIDLabel = UILabel(title:"AID: "+(UserAccountViewModel.sharedUserAccount.account?.uid ?? ""))
        }
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(imageView.snp.right).offset(10)
        }
        view.addSubview(AIDLabel)
        AIDLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(imageView.snp.right).offset(10)
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    typealias UIViewType = UIView
}
