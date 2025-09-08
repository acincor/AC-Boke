//
//  TypeStatusTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit
import SwiftUI


//let StatusCellNormalId2 = "StatusCellNormalId2"

class TypeStatusTableViewController: BlogTableViewController {
    var uid: String
    var specialClass: SpecialClass
    init(uid: String, specialClass: SpecialClass) {
        self.uid = uid
        self.specialClass = specialClass
        super.init(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func prepareTableView() {
        super.prepareTableView()
        refreshControl = ACRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
    }
    @objc override func loadData() {
        self.refreshControl?.beginRefreshing()
        //StatusDAL.clearDataCache()//删除缓存
        statusListViewModel.loadStatus(uid, specialClass: specialClass) { isSuccessful in
            Task { @MainActor in
                self.refreshControl?.endRefreshing()
                if !isSuccessful {
                    showError("加载数据错误，请稍后重试")
                    return
                }
                self.showPulldownTip()
                self.tableView.reloadData()
            }
        }
    }
    override func refreshSingleStatus(_ id: Int) {
        self.statusListViewModel.loadSingleStatus(id) { isSuccessful in
            if(isSuccessful) {
                self.tableView.reloadData()
            }
        }
    }
    private lazy var pulldownTipLabel: UILabel = {
        let label = UILabel(title: "", fontSize: 18,color: .white)
        label.backgroundColor = .red
        self.navigationController?.navigationBar.insertSubview(label, at: 0)
        return label
    }()
    private func showPulldownTip() {
        guard let count = statusListViewModel.pulldownCount else {
            return
        }
        pulldownTipLabel.text = (count == 0) ? NSLocalizedString("没有博客", comment: "") : String.localizedStringWithFormat(NSLocalizedString("刷新到%@条博客", comment: ""),"\(count)")
        let height: CGFloat = 44
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: height)
        pulldownTipLabel.frame = CGRectOffset(rect, 0, -2 * height)
        UIView.animate(withDuration: 1.0,animations: {
            self.pulldownTipLabel.frame = CGRectOffset(rect, 0, height)
        }) { _ in
            UIView.animate(withDuration: 1.0) {
                self.pulldownTipLabel.frame = CGRectOffset(rect, 0, -2 * height)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        if !userLogon {
            visitorView?.setupInfo(imageName: nil, title: NSLocalizedString("登陆一下，随时随地发现新鲜事", comment: ""))
            return
        }
    }
    override func deleteStatusInList(_ id: Int, _ row: Int) {
        NotificationCenter.default.post(name: Notification.Name("BKReloadHomePageDataNotification"), object: id)
        self.statusListViewModel.statusList.remove(at: row)
        self.tableView.reloadData()
    }
}
extension TypeStatusTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! StatusCell
        let vm = self.statusListViewModel.statusList[indexPath.row]
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.compose(_:)), for: .touchUpInside)
        return cell
    }
    @objc func compose(_ sender: UIButton) {
        let nav = ComposeViewController(nil,statusListViewModel.statusList[sender.tag].status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CommentTableViewController(statusListViewModel.statusList[indexPath.row])
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
}
