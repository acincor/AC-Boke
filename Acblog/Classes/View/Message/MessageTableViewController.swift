//
//  MessageTableViewController.swift
//  Acblog
//
//  Created by acincor on 2025/9/14.
//

import UIKit

class MessageTableViewController: UserTableViewController {
    override func specialClass() -> SpecialClass {
        return .friend
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let socketController = WebSocketController(to_uid: userListViewModel.list[indexPath.row].user.uid, username: userListViewModel.list[indexPath.row].user.user ?? "")
        let nav = UINavigationController(rootViewController: socketController)
        nav.modalPresentationStyle = .custom
        present(nav, animated: false)
    }
}
