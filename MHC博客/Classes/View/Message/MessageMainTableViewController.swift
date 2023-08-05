//
//  MessageMainTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

var to_user: String?
let FriendCellNormalId = "FriendCellNormalId"
let FriendNormalCellMargin = 1.5
class MessageTableViewController: VisitorTableViewController{
    var friendListViewModel = FriendListViewModel()
    private lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .white
        return indicator
    }()
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        //print(self.pullupView.isAnimating)
        StatusDAL.clearDataCache()
        friendListViewModel.loadFriend { (isSuccessed) in
            self.refreshControl?.endRefreshing()
            self.pullupView.stopAnimating()
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
            //print(listViewModel.statusList)
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogon {
            visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: "登陆后，别人评论你的微博，发给你的消息，都会在这里收到通知")
            return
        }
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCellNormalId)
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        tableView.tableFooterView = pullupView
        loadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendListViewModel.friendList.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let socketController = WebSocketController()
        socketController.to_uid = friendListViewModel.friendList[indexPath.row].friend.uid
        socketController.username = friendListViewModel.friendList[indexPath.row].friend.user
        let nav = UINavigationController(rootViewController: socketController)
        nav.modalPresentationStyle = .custom
        present(nav, animated: false)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = friendListViewModel.friendList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCellNormalId, for: indexPath) as! FriendCell
        cell.viewModel = vm
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.friendListViewModel.friendList[indexPath.row].rowHeight * FriendNormalCellMargin
    }
}



