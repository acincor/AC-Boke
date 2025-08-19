//
//  DiscoverTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/6.
//

import UIKit

@MainActor var MySearchTextField: UISearchController?

class DiscoverTableViewController: VisitorTableViewController, UISearchResultsUpdating, UISearchBarDelegate, @preconcurrency StatusCellDelegate {
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
    
    func statusCellDidClickUrl(url: URL) {
        let vc = ACWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
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
            self.listFilterTeams.statusList = dataList
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
                self.listFilterTeams.statusList = dataList
            }
        }
        self.tableView.reloadData()
    }
    var listFilterTeams = TypeNeedCacheListViewModel()
    @objc func action1(_ sender: UIButton) {
        NetworkTools.shared.deleteStatus(nil, nil, listFilterTeams.statusList[sender.tag].status.id) { Result, Error in
            if Error != nil {
                showError("出错了")
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                showError("不能删除别人的博客哦")
                return
            }
            showInfo("删除成功")
            StatusDAL.removeCache(self.listFilterTeams.statusList[sender.tag].status.id, .status)
            if let i = listViewModel.statusList.firstIndex(where: { vm in
                vm.status.id == self.listFilterTeams.statusList[sender.tag].status.id
            }){
                listViewModel.statusList.remove(at: i)
            }
            NotificationCenter.default.post(name: Notification.Name("BKReloadHomePageDataNotification"), object: nil)
            self.filterContentForSearchText("")
        }
    }
    @objc func action3(_ sender: UIButton) {
        guard (listFilterTeams.statusList[sender.tag].status.id > 0) else {
            showError("出错了")
            return
        }
        let nav = ComposeViewController(nil,listFilterTeams.statusList[sender.tag].status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.like(listFilterTeams.statusList[sender.tag].status.id) { Result, Error in
            if Error == nil {
                Task { @MainActor in
                    self.listFilterTeams.loadSingleStatus(self.listFilterTeams.statusList[sender.tag].status.id) { isSuccessful in
                        if(isSuccessful) {
                            self.tableView.reloadData()
                        }
                    }
                }
                if (Result as! [String:Any])["code"] as! String == "add" {
                    showAlert(.timelineIconLike, "你的点赞TA收到了")
                    return
                }
                showAlert(.timelineIconUnlike, "你的取消TA收到了")
                return
            }
            showError("出错了")
            return
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserAccountViewModel.sharedUserAccount.userLogon {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusCellNormalId, for: indexPath) as! StatusNormalCell
        if(indexPath.row > self.listFilterTeams.statusList.count - 1) {
            return cell
        }
        let vm = self.listFilterTeams.statusList[indexPath.row]
        cell.viewModel = vm
        cell.bottomView.deleteButton.tag = indexPath.row
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.setTitle("\(vm.status.like_count)", for: .normal)
        cell.bottomView.likeButton.setImage(.timelineIconUnlike, for: .normal)
        for like in vm.status.like_list {
            if UserAccountViewModel.sharedUserAccount.account?.uid == like["like_uid"] as? String {
                cell.bottomView.likeButton.setImage(.timelineIconLike, for: .normal)
                break
            }
        }
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.cellDelegate = self
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listFilterTeams.statusList.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row > self.listFilterTeams.statusList.count - 1) {
            return 0
        }
        return self.listFilterTeams.statusList[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CommentTableViewController(viewModel: listFilterTeams.statusList[indexPath.row])
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
