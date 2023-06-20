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
    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogon {
            visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: "登陆后，别人评论你的微博，发给你的消息，都会在这里收到通知")
            return
        }
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCellNormalId)
        friendListViewModel.loadFriend { isSuccessed in
            if isSuccessed {
                //print("已经结束了呢！")
                self.tableView.reloadData()
                return
            }
            SVProgressHUD.showInfo(withStatus: "出错了")
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendListViewModel.friendList.count
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



