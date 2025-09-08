//
//  DiscoverTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit

@MainActor var MySearchTextField: UISearchController?

class DiscoverTableViewController: BlogTableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text! as NSString)
    }
    @objc func refresh() {
        NetworkTools.shared.search(status: "") { Result, Error in
            self.refreshControl?.endRefreshing()
            var dataList = [StatusViewModel]()
            guard let Result = Result as? [[String:Any]] else{
                return
            }
            for i in Result{
                dataList.append(StatusViewModel(status: Status(dict: i)))
            }
            self.statusListViewModel.statusList = dataList
        }
        self.tableView.reloadData()
    }
    func filterContentForSearchText(_ searchText: NSString) {
        NetworkTools.shared.search(status: searchText as String) { Result, Error in
            var dataList = [StatusViewModel]()
            if Result != nil {
                for i in Result as! [[String:Any]]{
                    dataList.append(StatusViewModel(status: Status(dict: i)))
                }
                self.statusListViewModel.statusList = dataList
            }
        }
        self.tableView.reloadData()
    }
    override func deleteStatusInList(_ id: Int, _ row: Int) {
        NotificationCenter.default.post(name: Notification.Name("BKReloadHomePageDataNotification"), object: id)
        self.statusListViewModel.statusList.remove(at: row)
        self.tableView.reloadData()
    }
    @objc func compose(_ sender: UIButton) {
        guard (statusListViewModel.statusList[sender.tag].status.id > 0) else {
            showError("出错了")
            return
        }
        let nav = ComposeViewController(nil,statusListViewModel.statusList[sender.tag].status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    override func refreshSingleStatus(_ id: Int) {
        self.statusListViewModel.loadSingleStatus(id) { isSuccessful in
            if(isSuccessful) {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = nil
        if !userLogon {
            visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: NSLocalizedString("登陆后，能用搜索框搜索出自己想要的全新世界", comment: ""))
            return
        }
        filterContentForSearchText("")
        refreshControl = ACRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        prepare()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTableViewController", for: indexPath) as! StatusNormalCell
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! StatusCell
        if(indexPath.row > self.statusListViewModel.statusList.count - 1) {
            return cell
        }
        let vm = self.statusListViewModel.statusList[indexPath.row]
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.compose(_:)), for: .touchUpInside)
        return cell
    }
    func prepare() {
        MySearchTextField = UISearchController(searchResultsController: nil)
        MySearchTextField?.obscuresBackgroundDuringPresentation = false
        MySearchTextField?.searchResultsUpdater = self
        MySearchTextField?.searchBar.delegate = self
        MySearchTextField?.searchBar.sizeToFit()
        definesPresentationContext = true
        self.tableView.tableHeaderView = MySearchTextField?.searchBar
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row > self.statusListViewModel.statusList.count - 1) {
            return 0
        }
        return self.statusListViewModel.statusList[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CommentTableViewController(statusListViewModel.statusList[indexPath.row])
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
}
extension DiscoverTableViewController {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text! as NSString)
    }
}
