//
//  ProfileTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit
import SwiftUI
let WBUserProfileSelectedPhotoNotification = "WBUserProfileSelectedPhotoNotification"
let WBUserProfileSelectedPhotoIndexPathKey = "WBUserProfileSelectedPhotoIndexPathKey"
let WBUserProfileSelectedPhotoURLsKey = "WBUserProfileSelectedPhotoURLsKey"
class UserProfileViewController:UIViewController, UITextFieldDelegate,UITabBarDelegate {
    private var usernameLabel: String
    private var portrait: String
    private var label: String {
        let lb = "用户名："+usernameLabel
        return lb
    }
    init(portrait: String,usernameLabel: String,MID: String) {
        self.usernameLabel = usernameLabel
        self.portrait = portrait
        self.MID = MID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var MIDLabel: UILabel = UILabel(title: uidLabel)
    private var MID: String
    private var uidLabel: String {
        let lb = "MID:"+MID
        return lb
    }
    @objc func action() {
        NetworkTools.shared.addFriend(MID) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print("Result出现错误")
                //print(Error)
                return
            }
            guard let result = Result as? [String:Any] else {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print("result出现转换错误")
                return
            }
            if (result["error"] != nil) {
                SVProgressHUD.showInfo(withStatus: result["error"] as? String)
                //print("result出现error")
                return
            }
            guard let code = result["code"] as? String else {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print("result出现转换错误")
                return
            }
            if (code != "delete") {
                SVProgressHUD.showInfo(withStatus: "成功添加好友")
                //print("result出现error")
                ////print(result)
                return
            }
            SVProgressHUD.showInfo(withStatus: "成功删除/拉黑好友")
        }
    }
    private lazy var Label: UILabel = UILabel(title: label)
    private lazy var addButton = UIButton(title: "添加好友", fontSize: 14, color: .black, imageName: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: Notification.Name(WBUserProfileSelectedPhotoNotification), object: nil, queue: nil) {[weak self] n in
            guard let indexPath = n.userInfo?[WBUserProfileSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let urls = n.userInfo?[WBUserProfileSelectedPhotoURLsKey] as? [URL] else {
                return
            }
            guard let cell = n.object as? ProfileBrowserPresentDelegate else {
                return
            }
            let vc = ProfileBrowserViewController(urls: urls, indexPath: indexPath)
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self?.photoBrowserAnimator
            self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
            self?.present(vc, animated: true,completion: nil)
        }
        loadData()
    }
    private lazy var photoBrowserAnimator: ProfileBrowserAnimator = ProfileBrowserAnimator()
    lazy var iconView = UserProfilePictureView(viewModel:URL(string: portrait)!)
    @objc func loadData() {
        view.backgroundColor = .white
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
        view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(self.action), for: .touchUpInside)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom)
        }
        view.addSubview(MIDLabel)
        MIDLabel.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom)
        }
        view.addSubview(Label)
        Label.snp.makeConstraints { make in
            make.top.equalTo(MIDLabel.snp.bottom)
        }
        Label.sizeToFit()
        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.top.equalTo(Label.snp.bottom).offset(10)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        tabBar.delegate = self
        tabBar.items = [UITabBarItem(title: "点赞过的", image: UIImage(named: "timeline_icon_unlike"), tag: 0),UITabBarItem(title: "评论过的", image: UIImage(named: "timeline_icon_comment"), tag: 0)]
        // Do any additional setup after loading the view.
    }
    let tabBar = UITabBar()
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "点赞过的" {
            present(UINavigationController(rootViewController: LikeStatusTableViewController(uid: MID)), animated: true)
        } else {
            present(UINavigationController(rootViewController: CommentStatusTableViewController(uid: MID)), animated: true)
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
                //print(Result)
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
