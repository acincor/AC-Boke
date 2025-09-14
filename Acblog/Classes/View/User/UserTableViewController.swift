//
//  MessageMainTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit

let UserNormalCellMargin = 1.5
class UserTableViewController: VisitorTableViewController{
    var userListViewModel = UserListViewModel()
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        userListViewModel.loadFLFL(specialClass: specialClass) { (isSuccessful) in
            Task { @MainActor in
                self.refreshControl?.endRefreshing()
                if !isSuccessful {
                    showError("加载数据错误，请稍后再试")
                    return
                }
                self.tableView.reloadData()
            }
        }
    }
    init(specialClass: SpecialClass) {
        self.specialClass = specialClass
        super.init(nibName: nil, bundle: nil)
    }
    var specialClass: SpecialClass
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogon {
            visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: NSLocalizedString("登陆后，别人发给你的消息，你能在这里回复", comment: ""))
            return
        }
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCellNormalId)
        refreshControl = ACRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        loadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userListViewModel.list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = userListViewModel.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellNormalId, for: indexPath) as! UserCell
        cell.viewModel = vm
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.userListViewModel.list[indexPath.row].rowHeight * UserNormalCellMargin
    }
}



