//
//  DiscoverTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

var MySearchTextField: UISearchController?

class DiscoverTableViewController: VisitorTableViewController, UISearchResultsUpdating, UISearchBarDelegate, StatusCellDelegate {
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
    
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
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
            if Result != nil {
                for i in Result as! [[String:Any]]{
                    dataList.append(StatusViewModel(status: Status(dict: i)))
                }
                self.listFilterTeams = dataList
            }
            //SVProgressHUD.showInfo(withStatus: "没有博客")
        }
        self.tableView.reloadData()
    }
    func filterContentForSearchText(_ searchText: NSString) {
        /*
        let p1 = NSPredicate(format: "SELF.user CONTAINS %@ || SELF.status CONTAINS %@", searchText,searchText)
        if searchText.length == 0 {
            self.listFilterTeams = NSMutableArray(array: self.listTeams!)
            //self.tableView.reloadData()
            return
        }
        guard let tempArray = (self.listTeams?.filter{
            p1.evaluate(with: $0.status) }) as? NSArray else {
            return
        }
        self.listFilterTeams = NSMutableArray(array: tempArray)
         */
        
        NetworkTools.shared.search(status: searchText as String) { Result, Error in
            var dataList = [StatusViewModel]()
            if Result != nil {
                for i in Result as! [[String:Any]]{
                    dataList.append(StatusViewModel(status: Status(dict: i)))
                }
                self.listFilterTeams = dataList
            }
            //SVProgressHUD.showInfo(withStatus: "没有博客")
        }
        self.tableView.reloadData()
    }
    var listFilterTeams: [StatusViewModel]?
    @objc func action2(_ sender: UIBarButtonItem) {
        SVProgressHUD.show(withStatus: NSLocalizedString("加载中", comment: ""))
        NetworkTools.shared.addComment(id: listFilterTeams![sender.tag].status.id, sender.nav.textView.emoticonText) { Result, Error in
            SVProgressHUD.dismiss()
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                return
            }
            sender.nav.close()
        }
    }
    @objc func action1(_ sender: UIButton) {
        sender.identifier.bottomView.deleteBlog(listFilterTeams![sender.tag].status.id) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("不能删除别人的博客哦", comment: ""))
                return
            }
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("删除成功", comment: ""))
            StatusDAL.removeCache(self.listFilterTeams![sender.tag].status.id)
            if let i = listViewModel.statusList.firstIndex(where: { vm in
                vm.status.id == self.listFilterTeams![sender.tag].status.id
            }){
                listViewModel.statusList.remove(at: i)
            }
            NotificationCenter.default.post(name: Notification.Name("BKReloadHomePageDataNotification"), object: nil)
            self.filterContentForSearchText("")
        }
    }
    @objc func action3(_ sender: UIButton) {
        let nav = CommentViewController()
        guard (listFilterTeams![sender.tag].status.id > 0) else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
            return
        }
        let button = UIBarButtonItem(title: NSLocalizedString("发布", comment: ""), style: .plain, target: self, action: #selector(self.action2(_:)))
        button.tag = sender.tag
        button.nav = nav
        nav.navigationItem.rightBarButtonItem = button
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.like(listFilterTeams![sender.tag].status.id) { Result, Error in
            if Error == nil {
                if (Result as! [String:Any])["code"] as! String == "add" {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_like")!, status: NSLocalizedString("你的点赞TA收到了", comment: ""))
                } else {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_unlike")!, status: NSLocalizedString("你的取消TA收到了", comment: ""))
                }
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    SVProgressHUD.dismiss()
                }
                return
            }
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
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
        refreshControl = WBRefreshControl()
        //tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .plain)
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        //tableView.register(StatusNormalCell.self, forCellReuseIdentifier: "DiscoverTableViewController")
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)//StatusCellNormalId has been exist
        prepare()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTableViewController", for: indexPath) as! StatusNormalCell
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusCellNormalId, for: indexPath) as! StatusNormalCell
        if(indexPath.row > (self.listFilterTeams?.count ?? 0) - 1) {
            return cell
        }
        let vm = self.listFilterTeams?[indexPath.row] as? StatusViewModel
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.identifier = cell
        cell.bottomView.deleteButton.tag = indexPath.row
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        /*
        cell.bottomView.deleteButton.addAction(UIAction { action in
            cell.bottomView.deleteBlog(listFilterTeams![indexPath.row].status.id) { Result, Error in
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    return
                }
                if (Result as! [String:Any])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: "不能删除别人的博客哦")
                    return
                }
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("删除成功", comment: ""))
            }
        }, for: .touchUpInside)
         */
        cell.bottomView.commentButton.setTitle("\(listFilterTeams![indexPath.row].status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        let result = ["id":"\(listFilterTeams![indexPath.row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
        cell.bottomView.likeButton.setTitle("\(listFilterTeams![indexPath.row].status.like_count)", for: .normal)
        NetworkTools.shared.loadOneStatus(id: listFilterTeams![indexPath.row].status.id) { res, error in
            if error != nil {
                return
            }
            guard let list = res as? [String:Any] else {
                return
            }
            guard let like_list = list["like_list"] as? [[String:Any]] else {
                return
            }
            cell.bottomView.commentButton.setTitle(list["comment_count"] as? String, for: .normal)
            cell.bottomView.likeButton.setTitle(list["like_count"] as? String, for: .normal)
            for s in like_list {
                if result["like_uid"] as? String == s["like_uid"] as? String {
                    
                    cell.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_like"), for: .normal)
                    break
                } else {
                    cell.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
                }
            }
            if like_list.isEmpty {
                cell.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
            }
        }
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    var cell: StatusNormalCell?
    func prepare() {
        MySearchTextField = UISearchController(searchResultsController: nil)
        // 输入框提示内容
        
        MySearchTextField?.obscuresBackgroundDuringPresentation = false
        MySearchTextField?.searchResultsUpdater = self
        MySearchTextField?.searchBar.delegate = self
        MySearchTextField?.searchBar.sizeToFit()
        definesPresentationContext = true
        self.tableView.tableHeaderView = MySearchTextField?.searchBar
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listFilterTeams?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row > (self.listFilterTeams?.count ?? 0) - 1) {
            return 0
        }
        return self.listFilterTeams?[indexPath.row].rowHeight ?? 0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel = listFilterTeams![indexPath.row]
        let vc = CommentTableViewController()
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
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
extension DiscoverTableViewController {
func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    filterContentForSearchText(searchBar.text! as NSString)
}
}
