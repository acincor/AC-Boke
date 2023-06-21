//
//  DiscoverTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/6.
//

import UIKit

var MySearchTextField: UISearchController?
class DiscoverTableViewController: VisitorTableViewController, UISearchResultsUpdating, UISearchBarDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTableViewController", for: indexPath) as! StatusNormalCell
        cell.viewModel = self.listFilterTeams?[indexPath.row] as? StatusViewModel
        return cell
    }
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
