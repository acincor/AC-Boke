//
//  UIButton+Extension.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/7.
//

import Foundation
import UIKit
import SwiftUI
struct NavigationLinkView: View {
    @State var isShow = false
    @State var isShow2 = false
    var body: some View {
            NavigationView {
                List {
                    ImageDetailView()
                    NavigationLink(destination: MyDetailView (controller: UserAgreementViewController())) {
                        Text("用户协议")
                            .foregroundColor(.orange)
                    }
                    NavigationLink(destination: MyDetailView(controller: UINavigationController(rootViewController: ProfileTableViewController()))) {
                        Text("我的主页")
                            .foregroundColor(.orange)
                    }
                    if UserAccountViewModel.sharedUserAccount.userLogon {
                        NavigationLink(destination: MyDetailView(controller: LikeStatusTableViewController(uid: UserAccountViewModel.sharedUserAccount.account!.uid!))) {
                            Image("timeline_icon_like")
                            Text("点赞过的")
                                .foregroundColor(.orange)
                        }
                    } else {
                        NavigationLink(destination: MyDetailView(controller: OAuthViewController(.登录))) {
                            Image("timeline_icon_like")
                            Text("点赞过的")
                                .foregroundColor(.orange)
                        }
                    }
                    if UserAccountViewModel.sharedUserAccount.userLogon {
                        NavigationLink(destination: MyDetailView(controller: CommentStatusTableViewController(uid: UserAccountViewModel.sharedUserAccount.account!.uid!))) {
                            Image("timeline_icon_comment")
                            Text("评论过的")
                                .foregroundColor(.orange)
                        }
                    } else {
                        NavigationLink(destination: MyDetailView(controller: OAuthViewController(.登录))) {
                            Image("timeline_icon_comment")
                            Text("评论过的")
                                .foregroundColor(.orange)
                        }
                    }
                    if UserAccountViewModel.sharedUserAccount.userLogon {
                        NavigationLink(destination: MyDetailView(controller: BKLiveController())) {
                            Image("live_small_icon")
                                .background(Color.red)
                            Text("开始直播")
                                .foregroundColor(.orange)
                        }
                    } else {
                        NavigationLink(destination: MyDetailView(controller: OAuthViewController(.登录))) {
                            Image("live_small_icon")
                                .background(Color.red)
                            Text("开始直播")
                                .foregroundColor(.orange)
                        }
                    }
                    NavigationLink(destination: MyDetailView(controller:UINavigationController(rootViewController:logOffController(showing: self.$isShow))), isActive: self.$isShow) {
                        Text("注销账号")
                            .foregroundColor(.orange)
                    }
                    NavigationLink(destination: MyDetailView(controller:UINavigationController(rootViewController:logOutController(showing: self.$isShow2))), isActive: self.$isShow2) {
                        Text("退出登录")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationBarTitle("hi，"+(UserAccountViewModel.sharedUserAccount.account?.user ?? "未登录的用户"))
            .accentColor(.orange)
    }
}
struct MyDetailView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return controller.view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    var controller: UIViewController
    typealias UIViewType = UIView
}
struct ImageDetailView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        //let view = ProfilePictureView(viewModel: UserAccountViewModel.sharedUserAccount.portraitUrl)
        let view = UIView()
        let imageView = UIImageView()
        imageView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl, placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached])
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        let label = UILabel(title: UserAccountViewModel.sharedUserAccount.account!.user!)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(imageView.snp.right).offset(10)
        }
        let MIDLabel = UILabel(title:"MID: "+UserAccountViewModel.sharedUserAccount.account!.uid!)
        view.addSubview(MIDLabel)
        MIDLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(imageView.snp.right).offset(10)
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    typealias UIViewType = UIView
}
extension UIButton {
    convenience init(imageName:String,backImageName:String?) {
        self.init()
        setImage(UIImage(named: imageName), for: .normal)
        setImage(UIImage(named: imageName+"_highlighted"), for: .highlighted)
        if let backImageName = backImageName {
            setBackgroundImage(UIImage(named: backImageName), for: .normal)
            setBackgroundImage(UIImage(named: backImageName + "_highlighted"), for: .highlighted)
        }
        sizeToFit()
    }
    convenience init(title: String, color: UIColor, backImageName: String?, backColor: UIColor? = nil) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        if let backImageName = backImageName {
            setBackgroundImage(UIImage(named: backImageName), for: .normal)
        }
        backgroundColor = backColor
        sizeToFit()
    }
    convenience init(title: String, fontSize: CGFloat, color: UIColor, imageName: String?, backColor: UIColor? = nil) {
        self.init()
        setTitle(title, for: UIControl.State())
        setTitleColor(color, for: UIControl.State())
        if let imageName = imageName {
            setImage(UIImage(named: imageName), for: UIControl.State())
        }
        backgroundColor = backColor
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        sizeToFit()
    }
    func setValue(value: String,key: String) {
        objc_setAssociatedObject(self, &(associatedKey.value_list), [key:value], objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    func getValue() -> [[String:String]]{
        return objc_getAssociatedObject(self, &(associatedKey.value_list)) as! [[String:String]]
    }
    struct associatedKey {
        static var value_list: [[String:String]] = []
    }
}
