//
//  ProfileTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit
import SwiftUI

let WBProfileSelectedPhotoNotification = "WBProfileSelectedPhotoNotification"
let WBProfileSelectedPhotoIndexPathKey = "WBProfileSelectedPhotoIndexPathKey"
let WBProfileSelectedPhotoURLsKey = "WBProfileSelectedPhotoURLsKey"
class ProfileTableViewController: VisitorTableViewController, UITextFieldDelegate, UITabBarDelegate {
    private var usernameLabel: String {
        return UserAccountViewModel.sharedUserAccount.account?.user ?? "用户未登录"
    }
    private var label: String {
        let lb = "用户名："
            return lb
    }
    private lazy var MIDLabel: UILabel = UILabel(title: label)
    private var uidLabel: String {
        let lb = "MID:"+UserAccountViewModel.sharedUserAccount.account!.uid!
            return lb
    }
    private var renameButton: UITextField = UITextField()
    private lazy var Label: UILabel = UILabel(title: label)
    let userAgreementButton = UIButton(title: "用户协议", fontSize: 18, color: .red, imageName: nil, backColor: UIColor.gray.withAlphaComponent(0.1))
    let liveButton = UIButton(title: "开始直播", fontSize: 18, color: .red, imageName: nil, backColor: UIColor.gray.withAlphaComponent(0.1))
    let logOffButton = UIButton(title: "注销账号", fontSize: 18, color: .red, imageName: nil, backColor: UIColor.gray.withAlphaComponent(0.1))
    let expiresUserButton = UIButton(title: "退出登录", fontSize: 18, color: .red, imageName: nil, backColor: UIColor.gray.withAlphaComponent(0.1))
    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogon {
            visitorView?.setupInfo(imageName: "visitordiscover_image_profile", title: "登陆后，你的微博，相册、个人资料会显示在这里，展示给别人")
            return
        }
        view.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(50)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        let imageView = UIImageView()
        imageView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl, placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached])
        iconView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.centerX.equalTo(view.snp.centerX)
                make.top.equalTo(view.snp.top).offset(50)
                make.width.equalTo(90)
                make.height.equalTo(90)
            }
        iconView.layer.cornerRadius = 15
        view.addSubview(Label)
        renameButton = UITextField()
        renameButton.text = usernameLabel
        view.addSubview(renameButton)
        view.addSubview(logOffButton)
        view.addSubview(liveButton)
        view.addSubview(userAgreementButton)
        view.addSubview(expiresUserButton)
        view.addSubview(MIDLabel)
        view.addSubview(tabBar)
        loadData()
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        NotificationCenter.default.addObserver(forName: Notification.Name(WBProfileSelectedPhotoNotification), object: nil, queue: nil) {[weak self] n in
            guard let indexPath = n.userInfo?[WBProfileSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let urls = n.userInfo?[WBProfileSelectedPhotoURLsKey] as? [URL] else {
                return
            }
            guard let cell = n.object as? ProfileBrowserPresentDelegate else {
                return
            }
            let vc = UserProfileBrowserViewController(urls: urls, indexPath: indexPath)
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self?.photoBrowserAnimator
            self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
            self?.present(vc, animated: true,completion: nil)
            
        }
        
    }
    lazy var iconView = ProfilePictureView(viewModel: UserAccountViewModel.sharedUserAccount.portraitUrl)
    private lazy var photoBrowserAnimator: ProfileBrowserAnimator = ProfileBrowserAnimator()
    @objc func loadData() {
        refreshControl?.beginRefreshing()
        do {
            iconView.removeFromSuperview()
            view.addSubview(iconView)
            iconView.snp.makeConstraints { make in
                make.centerX.equalTo(view.snp.centerX)
                make.top.equalTo(view.snp.top).offset(50)
                make.width.equalTo(90)
                make.height.equalTo(90)
            }
            let imageView = UIImageView()
            imageView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl, placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached])
            iconView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.centerX.equalTo(view.snp.centerX)
                    make.top.equalTo(view.snp.top).offset(50)
                    make.width.equalTo(90)
                    make.height.equalTo(90)
                }
            iconView.layer.cornerRadius = 15
            MIDLabel.removeFromSuperview()
            MIDLabel = UILabel(title: uidLabel)
            view.addSubview(MIDLabel)
            MIDLabel.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom)
            }
            Label.removeFromSuperview()
            Label = UILabel(title: label)
            view.addSubview(Label)
            Label.snp.makeConstraints { make in
                make.top.equalTo(MIDLabel.snp.bottom)
            }
            Label.sizeToFit()
            renameButton.removeFromSuperview()
            renameButton = UITextField()
            renameButton.text = usernameLabel
            view.addSubview(renameButton)
            renameButton.snp.makeConstraints { make in
                make.left.equalTo(Label.snp.right)
                make.top.equalTo(MIDLabel.snp.bottom)
            }
            renameButton.delegate = self
            renameButton.sizeToFit()
            userAgreementButton.removeFromSuperview()
            view.addSubview(userAgreementButton)
            userAgreementButton.snp.makeConstraints { make in
                make.top.equalTo(renameButton.snp.bottom).offset(20)
                make.width.equalTo(UIScreen.main.bounds.width)
            }
            userAgreementButton.layer.cornerRadius = 15
            userAgreementButton.addTarget(self, action: #selector(self.userAgreementButtonTouchAction), for: .touchDown)
            liveButton.removeFromSuperview()
            view.addSubview(liveButton)
            liveButton.snp.makeConstraints { make in
                make.top.equalTo(userAgreementButton.snp.bottom).offset(10)
                make.width.equalTo(UIScreen.main.bounds.width)
            }
            liveButton.layer.cornerRadius = 15
            liveButton.addTarget(self, action: #selector(self.liveButtonTouchAction), for: .touchDown)
            expiresUserButton.removeFromSuperview()
            view.addSubview(expiresUserButton)
            expiresUserButton.snp.makeConstraints { make in
                make.top.equalTo(liveButton.snp.bottom).offset(10)
                make.width.equalTo(UIScreen.main.bounds.width)
            }
            expiresUserButton.layer.cornerRadius = 15
            expiresUserButton.addTarget(self, action: #selector(self.expiresUserButtonTouchAction), for: .touchDown)
            logOffButton.removeFromSuperview()
            view.addSubview(logOffButton)
            logOffButton.snp.makeConstraints { make in
                make.top.equalTo(expiresUserButton.snp.bottom).offset(10)
                make.width.equalTo(UIScreen.main.bounds.width)
            }
            logOffButton.layer.cornerRadius = 15
            logOffButton.addTarget(self, action: #selector(self.logOffUserButtonTouchAction), for: .touchDown)
            // Do any additional setup after loading the view.
            tabBar.removeFromSuperview()
            view.addSubview(tabBar)
            tabBar.snp.makeConstraints { make in
                make.top.equalTo(logOffButton.snp.bottom).offset(10)
                make.width.equalTo(UIScreen.main.bounds.width)
            }
            tabBar.delegate = self
            tabBar.items = [UITabBarItem(title: "点赞过的", image: UIImage(named: "timeline_icon_unlike"), tag: 0),UITabBarItem(title: "评论过的", image: UIImage(named: "timeline_icon_comment"), tag: 0)]
        } catch {
            SVProgressHUD.show(withStatus: "图片加载错误")
            return
        }
        refreshControl?.endRefreshing()
    }
    let tabBar = UITabBar()
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "点赞过的" {
            present(UINavigationController(rootViewController: LikeStatusTableViewController(uid: UserAccountViewModel.sharedUserAccount.account!.uid!)), animated: true)
        } else {
            present(UINavigationController(rootViewController: CommentStatusTableViewController(uid: UserAccountViewModel.sharedUserAccount.account!.uid!)), animated: true)
        }
    }
    @objc func liveButtonTouchAction() {
        let nav = UINavigationController(rootViewController: BKLiveController())
        nav.modalPresentationStyle = .custom
        present(nav, animated: true)
    }
    @objc func closeUserAgreement() {
        controller.dismiss(animated: true)
    }
    let controller = UIViewController()
    
    @objc func userAgreementButtonTouchAction() {
        let textView = UITextView(frame: UIScreen.main.bounds)
        guard let userAgreement = Bundle.main.path(forResource: "用户协议", ofType: "txt") else {
            SVProgressHUD.showInfo(withStatus: "似乎找不到目录")
            return
        }
        do{
            let readStr:NSString=try NSString(contentsOfFile: userAgreement, encoding: String.Encoding.utf8.rawValue)
            textView.text = readStr as String
            textView.isEditable = false
            controller.title = "用户协议"
            controller.view = textView
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(self.closeUserAgreement))
            controller.navigationItem.leftBarButtonItem?.tintColor = .red
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .custom
            present(nav, animated: true)
        }catch _ {
        //print(error.localizedDescription)
        //print("文件读取失败，可能是资源找不到")
        }
    }
    @objc func expiresUserButtonTouchAction(){
        NetworkTools.shared.ExpiresTheToken { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                return
            }
            if(Result as! [String:Any])["msg"] != nil {
                print(Result)
                NotificationCenter.default.post(name: .init(rawValue: .init("WBSwitchRootViewControllerLogOutNotification")), object: "logOut")
                UserAccountViewModel.sharedUserAccount.account = nil
            }
        }
    }
    @objc func logOffUserButtonTouchAction() {
        NetworkTools.shared.logOff { Result, Error in
            if Error != nil {
                print(Error)
                SVProgressHUD.showInfo(withStatus: "出错了")
                return
            }
            print(Result)
            if(Result as! [String:Any])["msg"] != nil {
                //print(Result)
                NotificationCenter.default.post(name: .init(rawValue: .init("WBSwitchRootViewControllerLogOutNotification")), object: nil)
                UserAccountViewModel.sharedUserAccount.account = nil
            }
        }
    }
    @objc func action1(_ sender: UITextField) -> Bool{
        NetworkTools.shared.rename(rename: sender.text!) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                sender.identifier = "false"
                return
            }
            if(Result as! [String:Any])["msg"] != nil {
                //print(Result)
                UserAccountViewModel.sharedUserAccount.account = UserAccount(dict: (Result as! [String: Any])["usermsg"] as! [String:Any])
                UserAccountViewModel.sharedUserAccount.loadUserInfo(account: UserAccountViewModel.sharedUserAccount.account!) {isSuccessed in
                    if isSuccessed {
                        SVProgressHUD.showInfo(withStatus: "改名成功")
                        sender.identifier = "true"
                    }
                }
            }
        }
        return sender.identifier == "true" ? true : false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return action1(textField)
    }
    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
