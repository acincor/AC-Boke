//
//  DiscoverTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

var MySearchTextField: UISearchController?
class DiscoverTableViewController: VisitorTableViewController, UISearchResultsUpdating, UISearchBarDelegate, StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text! as NSString)
    }
    func filterContentForSearchText(_ searchText: NSString) {
        let p1 = NSPredicate(format: "SELF.user CONTAINS %@ || SELF.status CONTAINS %@", searchText,searchText)
        print(p1.predicateFormat)
        if searchText.length == 0 {
            self.listFilterTeams = NSMutableArray(array: self.listTeams!)
            self.tableView.reloadData()
            return
        }
        guard let tempArray = (self.listTeams?.filter{
            p1.evaluate(with: $0.status) }) as? NSArray else {
            return
        }
        self.listFilterTeams = NSMutableArray(array: tempArray)
        self.tableView.reloadData()
    }
    var listTeams: [StatusViewModel]?
    var listFilterTeams: NSArray?
    @objc func action2(_ sender: UIButton) {
        NetworkTools.shared.addComment(id: listViewModel.statusList[sender.tag].status.id, sender.nav.textView.emoticonText) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print(Error)
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print(Error)
                return
            }
            sender.nav.close()
        }
    }
    @objc func action1(_ sender: UIButton) {
        sender.identifier.bottomView.deleteBlog(listViewModel.statusList[sender.tag].status.id) { Result, Error in
            //print(listViewModel.statusList[indexPath.row].status.id)
            //print(UserAccountViewModel.sharedUserAccount.accessToken)
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                print(Error)
                return
            }
            print(Result as! [String:Any])
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: "不能删除别人的博客哦")
                //print((Result as! [String:String])["error"])
                return
            }
            SVProgressHUD.showInfo(withStatus: "删除成功")
            self.loadData()
        }
    }
    @objc func action3(_ sender: UIButton) {
        let nav = CommentViewController()
        let button = UIButton(title: "发表", color: .orange,backImageName: nil)
        //print(listViewModel.statusList[indexPath.row].status.id)
        //print(nav.textView.text!)
        guard (listViewModel.statusList[sender.tag].status.id > 0) else {
            SVProgressHUD.showInfo(withStatus: "出错了")
            return
        }
        button.nav = nav
        button.tag = sender.tag
        button.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        if sender.int == 1 {
            //print(id ?? 0)
            NetworkTools.shared.deleteLike(listViewModel.statusList[sender.tag].status.id) { Result, Error in
                if Error == nil {
                    //print(Result as! [String:Any])
                    sender.int = 0
                    self.loadData()
                    return
                }
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print(Error)
                return
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                NetworkTools.shared.addLike(listViewModel.statusList[sender.tag].status.id) { Result, Error in
                    if Error == nil {
                        //print(Result as! [String:Any])
                        
                        sender.int = 1
                        self.loadData()
                        return
                    }
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        visitorView?.setupInfo(imageName: "visitordiscover_image_message", title: "登陆后，最新、最热微博尽在掌握，不再会与时事潮流擦肩而过")
        if !userLogon {
            return
        }
        self.listTeams = listViewModel.statusList
        filterContentForSearchText("")
        refreshControl = WBRefreshControl()
        //tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .plain)
        refreshControl?.addTarget(self, action: Selector("loadData"), for: .valueChanged)
        tableView.tableFooterView = pullupView
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: "DiscoverTableViewController")
        prepare()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    private lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .white
        return indicator
    }()
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        //print(self.pullupView.isAnimating)
        StatusDAL.clearDataCache()
        listViewModel.loadStatus(isPullup: pullupView.isAnimating) { (isSuccessed) in
            self.refreshControl?.endRefreshing()
            self.pullupView.stopAnimating()
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
            self.listFilterTeams = listViewModel.statusList as NSArray
            //print(listViewModel.statusList)
            self.tableView.reloadData()
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTableViewController", for: indexPath) as! StatusNormalCell
        var vm = self.listFilterTeams?[indexPath.row] as? StatusViewModel
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.identifier = cell
        cell.bottomView.deleteButton.tag = indexPath.row
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        /*
        cell.bottomView.deleteButton.addAction(UIAction { action in
            cell.bottomView.deleteBlog(listViewModel.statusList[indexPath.row].status.id) { Result, Error in
                //print(listViewModel.statusList[indexPath.row].status.id)
                //print(UserAccountViewModel.sharedUserAccount.accessToken)
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
                if (Result as! [String:Any])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: "不能删除别人的博客哦")
                    //print((Result as! [String:String])["error"])
                    return
                }
                SVProgressHUD.showInfo(withStatus: "删除成功")
            }
        }, for: .touchUpInside)
         */
        cell.bottomView.commentButton.setTitle("\(listViewModel.statusList[indexPath.row].status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.setTitle("\(listViewModel.statusList[indexPath.row].status.like_count)", for: .normal)
        NotificationCenter.default.post(name: Notification.Name("BKIfLikeIsTrueLightIt"), object: ["cell":cell,"indexPath":indexPath],userInfo: ["hello":"l"])
        cell = self.cell!
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    var cell: StatusNormalCell?
    func prepare() {
        MySearchTextField = UISearchController(searchResultsController: nil)
        // 输入框提示内容
        MySearchTextField?.dimsBackgroundDuringPresentation = false
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
        return (self.listFilterTeams?[indexPath.row] as! StatusViewModel).rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        id = indexPath.row
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
