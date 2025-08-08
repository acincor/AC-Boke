//
//  ProfileTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit
import SwiftUI
import SVProgressHUD
class ProfileTableViewController: VisitorTableViewController {
    var account: UserViewModel?
    private lazy var addButton = UIButton(title: NSLocalizedString("添加好友", comment: ""), fontSize: 14, color: UIColor(white: 0.6, alpha: 1.0), imageName: nil)
    private var usernameLabel: String {
        if account == nil {
            return (UserAccountViewModel.sharedUserAccount.account?.user ?? "")
        }
        return account?.user.user ?? NSLocalizedString("用户未登录", comment: "")
    }
    @objc func action() {
        NetworkTools.shared.addFriend("\(account!.user.uid)") { Result, Error in
            
            if Error != nil {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                }
                return
            }
            guard let result = Result as? [String:Any] else {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                }
                return
            }
            if (result["error"] != nil) {
                let err = result["error"] as? String
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: err)
                }
                return
            }
            guard let code = result["code"] as? String else {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                }
                return
            }
            if (code != "delete") {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("成功添加好友", comment: ""))
                }
                return
            }
            Task { @MainActor in
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("成功删除/拉黑好友", comment: ""))
            }
        }
    }
    private var label: String {
        let lb = NSLocalizedString("用户名：", comment: "")
        return lb
    }
    init(account: UserViewModel?) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var MIDLabel: UILabel = UILabel(title: label)
    private var uidLabel: String {
        if account == nil {
            return "MID:" + (UserAccountViewModel.sharedUserAccount.account?.uid ?? "")
        }
        let lb = "MID:\(account?.user.uid ?? 0)"
        return lb
    }
    private var renameButton: UIButton = UIButton(title: NSLocalizedString("编辑", comment: ""), color: .orange, backImageName: nil)
    private var name: UITextField = UITextField()
    private lazy var Label: UILabel = UILabel(title: label)
    //let liveButton = UIButton(title: "开始直播", fontSize: 18, color: .red, imageName: nil, backColor: UIColor.gray.withAlphaComponent(0.1))
    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogon {
            visitorView?.setupInfo(imageName: "visitordiscover_image_profile", title: NSLocalizedString("登陆后，你的个人信息、直播操作、退登注销将会在这里展示", comment: ""))
            return
        }
        view.addSubview(iconView)
        if account != nil {
            iconView.kf.setImage(with: account?.userProfileUrl)
        }
        iconView.kf.setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl)
        let g = UITapGestureRecognizer(target: self, action: #selector(self.action2))
        iconView.addGestureRecognizer(g)
        iconView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(50)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        iconView.layer.cornerRadius = 15
        if !isMe {
            view.addSubview(addButton)
        }
        view.addSubview(Label)
        if isMe {
            view.addSubview(renameButton)
        }
        //view.addSubview(liveButton)
        view.addSubview(MIDLabel)
        loadData()
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
    }
    var isMe: Bool {
        if account == nil {
            return true
        }
        return false
    }
    @objc func action2() {
        var vc: UserProfileBrowserViewController
        if isMe {
            vc = UserProfileBrowserViewController(url: UserAccountViewModel.sharedUserAccount.portraitUrl,style: .Me)
        } else if let account = account{
            vc = UserProfileBrowserViewController(url: account.userProfileUrl,style: .SomeBody)
        } else {
            return
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: true,completion: nil)
    }
    lazy var iconView = UIImageView()
    @objc func loadData() {
        refreshControl?.beginRefreshing()
        iconView.removeFromSuperview()
        if account != nil {
            iconView.kf.setImage(with: account?.userProfileUrl)
        }
        iconView.kf.setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl)
        iconView.layer.cornerRadius = 5
        iconView.clipsToBounds = true
        let g = UITapGestureRecognizer(target: self, action: #selector(self.action2))
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(g)
        view.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(50)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        if account != nil {
            addButton.removeFromSuperview()
            view.addSubview(addButton)
            addButton.addTarget(self, action: #selector(self.action), for: .touchUpInside)
            addButton.snp.makeConstraints { make in
                make.top.equalTo(iconView.snp.bottom)
            }
        }
        MIDLabel.removeFromSuperview()
        MIDLabel = UILabel(title: uidLabel)
        view.addSubview(MIDLabel)
        if isMe {
            MIDLabel.snp.makeConstraints { make in
                make.top.equalTo(iconView.snp.bottom)
            }
        } else {
            MIDLabel.snp.makeConstraints { make in
                make.top.equalTo(addButton.snp.bottom)
            }
        }
        Label.removeFromSuperview()
        Label = UILabel(title: label)
        view.addSubview(Label)
        Label.snp.makeConstraints { make in
            make.top.equalTo(MIDLabel.snp.bottom)
        }
        Label.sizeToFit()
        name.removeFromSuperview()
        name = UITextField()
        name.text = usernameLabel
        view.addSubview(name)
        name.snp.makeConstraints { make in
            make.left.equalTo(Label.snp.right)
            make.top.equalTo(MIDLabel.snp.bottom).offset(-3)
        }
        name.isEnabled = false
        if isMe {
            renameButton.removeFromSuperview()
            view.addSubview(renameButton)
            renameButton.snp.makeConstraints { make in
                make.top.equalTo(Label.snp.bottom)
            }
            renameButton.addTarget(self, action: #selector(self.touchUpInside), for: .touchUpInside)
        }
        name.sizeToFit()
        //renameButton.sizeToFit()
        /*
         view.addSubview(userAgreementButton)
         userAgreementButton.snp.makeConstraints { make in
         make.top.equalTo(renameButton.snp.bottom).offset(20)
         make.width.equalTo(UIScreen.main.bounds.width)
         }
         userAgreementButton.layer.cornerRadius = 15
         userAgreementButton.addTarget(self, action: #selector(self.userAgreementButtonTouchAction), for: .touchDown)
         */
        
        //liveButton.removeFromSuperview()
        //view.addSubview(liveButton)
        /*
         liveButton.snp.makeConstraints { make in
         make.top.equalTo(userAgreementButton.snp.bottom).offset(10)
         make.width.equalTo(UIScreen.main.bounds.width)
         }
         liveButton.layer.cornerRadius = 15
         liveButton.addTarget(self, action: #selector(self.liveButtonTouchAction), for: .touchDown)
         */
        /*
         expiresUserButton.removeFromSuperview()
         view.addSubview(expiresUserButton)
         expiresUserButton.snp.makeConstraints { make in
         //make.top.equalTo(liveButton.snp.bottom).offset(10)
         make.top.equalTo(userAgreementButton.snp.bottom).offset(10)
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
         */
        refreshControl?.endRefreshing()
    }
    @objc func liveButtonTouchAction() {
        let nav = UINavigationController(rootViewController: BKLiveController())
        nav.modalPresentationStyle = .custom
        present(nav, animated: true)
    }
    @objc func touchUpInside() {
        if renameButton.largeContentTitle == NSLocalizedString("编辑", comment: "") {
            name.isEnabled = true
            renameButton.removeFromSuperview()
            renameButton = UIButton(title: NSLocalizedString("完成", comment: ""), color: .orange, backImageName: nil)
            view.addSubview(renameButton)
            renameButton.snp.makeConstraints { make in
                make.top.equalTo(Label.snp.bottom)
            }
            renameButton.addTarget(self, action: #selector(self.touchUpInside), for: .touchUpInside)
        } else {
            name.isEnabled = false
            NetworkTools.shared.rename(rename: name.text!) { Result, Error in
                Task { @MainActor in
                    if Error != nil {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                        return
                    }
                }
                
                guard let res = Result as? [String:Any] else {
                    Task { @MainActor in
                        let controller = UIAlertController(title: NSLocalizedString("错误", comment: ""), message: NSLocalizedString("加载数据错误，请稍后重试", comment: ""), preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        self.present(controller, animated: true)
                    }
                    return
                }
                
                guard res["msg"] is Int else{
                    Task { @MainActor in
                        let controller = UIAlertController(title: NSLocalizedString("错误", comment: ""), message: NSLocalizedString("改名失败", comment: ""), preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(controller, animated: true)
                    }
                    return
                }
                Task { @MainActor in
                    UserAccountViewModel.sharedUserAccount.loadUserInfo(account: UserAccountViewModel.sharedUserAccount.account!) { [self]isSuccessed in
                        Task { @MainActor in
                            if isSuccessed {
                                SVProgressHUD.showInfo(withStatus: NSLocalizedString("改名成功", comment: ""))
                                renameButton.removeFromSuperview()
                                renameButton = UIButton(title: NSLocalizedString("编辑", comment: ""), color: .orange, backImageName: nil)
                                view.addSubview(renameButton)
                                renameButton.snp.makeConstraints { make in
                                    make.top.equalTo(Label.snp.bottom)
                                }
                                renameButton.addTarget(self, action: #selector(self.touchUpInside), for: .touchUpInside)
                            }
                        }
                    }
                }
            }
        }
    }
    /*
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
     }
     }
     */
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
