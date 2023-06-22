//
//  ProfileTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

class ProfileTableViewController: VisitorTableViewController {
    private var usernameLabel: String {
        return UserAccountViewModel.sharedUserAccount.account?.user ?? "用户未登录"
    }
    private var label: String {
            var lb = "用户名："+usernameLabel+"\n"
            return lb
    }
    private lazy var Label: UILabel = UILabel(title: label)
    private lazy var iconView: StatusPictureView = {
        let iv = StatusPictureView()
        iv.layer.cornerRadius = 45
        iv.layer.masksToBounds = true
        return iv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserAccountViewModel.sharedUserAccount.userLogon == false {
            visitorView?.setupInfo(imageName: "visitordiscover_image_profile", title: "登陆后，你的微博，相册、个人资料会显示在这里，展示给别人")
            return
        }
        view.addSubview(Label)
        view.addSubview(iconView)
        loadData()
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
    }
    @objc func loadData() {
        refreshControl?.beginRefreshing()
        iconView.backgroundColor = .yellow
        do {
            let imageView = UIImageView()
            imageView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl, placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached])
                iconView.snp.makeConstraints { make in
                    make.centerX.equalTo(view.snp.centerX)
                    make.top.equalTo(view.snp.top).offset(50)
                    make.width.equalTo(90)
                    make.height.equalTo(90)
                }
                iconView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.centerX.equalTo(view.snp.centerX)
                    make.top.equalTo(view.snp.top).offset(50)
                    make.width.equalTo(90)
                    make.height.equalTo(90)
                }
            Label.removeFromSuperview()
            Label = UILabel(title: label)
            
            view.addSubview(Label)
            Label.snp.makeConstraints { make in
                    make.top.equalTo(iconView.snp.bottom)
                }
            Label.sizeToFit()
                // Do any additional setup after loading the view.
        } catch {
            SVProgressHUD.show(withStatus: "图片加载错误")
            return
        }
        refreshControl?.endRefreshing()
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
