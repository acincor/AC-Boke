//
//  MessageMainTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

var to_user: String?
let UserCellNormalId = "UserCellNormalId"
let UserNormalCellMargin = 1.5
class MessageTableViewController: VisitorTableViewController{
    var friendListViewModel = FriendListViewModel()
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        friendListViewModel.loadFriend { (isSuccessed) in
            self.refreshControl?.endRefreshing()
            if !isSuccessed {
                
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后再试", comment: ""))
                return
            }
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogon {
            visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: NSLocalizedString("登陆后，别人发给你的消息，你能在这里回复", comment: ""))
            return
        }
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCellNormalId)
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        loadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendListViewModel.friendList.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let socketController = WebSocketController(to_uid: friendListViewModel.friendList[indexPath.row].user.uid, username: friendListViewModel.friendList[indexPath.row].user.user ?? "")
        let nav = UINavigationController(rootViewController: socketController)
        nav.modalPresentationStyle = .custom
        present(nav, animated: false)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = friendListViewModel.friendList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellNormalId, for: indexPath) as! UserCell
        cell.viewModel = vm
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.friendListViewModel.friendList[indexPath.row].rowHeight * UserNormalCellMargin
    }
}



