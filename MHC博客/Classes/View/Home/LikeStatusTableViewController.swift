//
//  LikeStatusTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit
import SwiftUI


let LikeStatusCellNormalId = "LikeStatusCellNormalId"
let likeListViewModel = LikeStatusListViewModel()
class LikeStatusTableViewController: VisitorTableViewController {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    private func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: LikeStatusCellNormalId)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = 400
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
    }
    init(uid: String) {
        self.uid = uid
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var uid: String
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        likeListViewModel.loadStatus(uid) { (isSuccessed) in
            self.refreshControl?.endRefreshing()
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("暂无点赞任何博客哦！", comment: ""))
                likeListViewModel.statusList = []
                self.tableView.reloadData()
                return
            }
            self.showPulldownTip()
            self.tableView.reloadData()
        }
    }
    private lazy var pulldownTipLabel: UILabel = {
        let label = UILabel(title: "", fontSize: 18,color: .white)
        label.backgroundColor = .red
        self.navigationController?.navigationBar.insertSubview(label, at: 0)
        return label
    }()
    private func showPulldownTip() {
        guard let count = likeListViewModel.pulldownCount else {
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
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: NSLocalizedString("登陆一下，随时随地发现新鲜事", comment: ""))
            return
        }
        
        loadData()
        prepareTableView()
    }
    @objc func action(sender: UITapGestureRecognizer) {
        let dict = ["portrait": sender.sender3, "user": sender.sender2, "uid": sender.sender]
        let uvm = UserViewModel(user: Account(dict: dict))
        present(UINavigationController(rootViewController: UIHostingController(rootView: UserNavigationLinkView(account: uvm, uid: sender.sender))), animated: true)
    }

    var cell: StatusCell?
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
}
extension LikeStatusTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeListViewModel.statusList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = likeListViewModel.statusList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LikeStatusCellNormalId, for: indexPath) as! StatusCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.identifier = cell
        cell.bottomView.deleteButton.tag = indexPath.row
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        let g = UITapGestureRecognizer(target: self, action: #selector(self.action(sender:)))
        guard let viewModel = cell.topView.viewModel as? StatusViewModel else {
            return cell
        }
        g.sender = "\(viewModel.status.uid)"
        g.sender2 = "\(viewModel.status.user ?? "")"
        g.sender3 = "\(viewModel.status.portrait ?? "")"
        cell.topView.iconView.addGestureRecognizer(g)
        //cell.bottomView.commentButton.setTitle("\(likeListViewModel.statusList[indexPath.row].status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        let result = ["id":"\(likeListViewModel.statusList[indexPath.row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
        cell.bottomView.likeButton.setTitle("\(likeListViewModel.statusList[indexPath.row].status.like_count)", for: .normal)
        NetworkTools.shared.loadOneStatus(id: likeListViewModel.statusList[indexPath.row].status.id) { res, error in
            if error != nil {
                return
            }
            guard let list = res as? [String:Any] else {
                return
            }
            cell.bottomView.commentButton.setTitle(list["comment_count"] as? String, for: .normal)
            cell.bottomView.likeButton.setTitle(list["like_count"] as? String, for: .normal)
            guard let like_list = list["like_list"] as? [[String:Any]] else {
                return
            }
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
        //cell = self.cell!
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    @objc func action2(_ sender: UIBarButtonItem) {
        SVProgressHUD.show(withStatus: NSLocalizedString("加载中", comment: ""))
        NetworkTools.shared.addComment(id: likeListViewModel.statusList[sender.tag].status.id, sender.nav.textView.emoticonText) { Result, Error in
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
        sender.identifier.bottomView.deleteBlog(likeListViewModel.statusList[sender.tag].status.id) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("不能删除别人的博客哦", comment: ""))
                return
            }
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("删除成功", comment: ""))
            self.loadData()
            StatusDAL.removeCache(likeListViewModel.statusList[sender.tag].status.id)
            if let i = listViewModel.statusList.firstIndex(where: { vm in
                vm.status.id == likeListViewModel.statusList[sender.tag].status.id
            }){
                listViewModel.statusList.remove(at: i)
            }
            NotificationCenter.default.post(name: Notification.Name("BKReloadHomePageDataNotification"), object: nil)
        }
    }
    @objc func action3(_ sender: UIButton) {
        let nav = CommentViewController()
        let button = UIBarButtonItem(title: NSLocalizedString("发布", comment: ""), style: .plain, target: self, action: #selector(self.action2(_:)))
        guard (likeListViewModel.statusList[sender.tag].status.id > 0) else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
            return
        }
        button.tag = sender.tag
        button.nav = nav
        nav.navigationItem.rightBarButtonItem = button
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.like(likeListViewModel.statusList[sender.tag].status.id) { Result, Error in
            if Error == nil {
                if (Result as! [String:Any])["code"] as! String == "add" {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_like")!, status: NSLocalizedString("你的点赞TA收到了", comment: ""))
                } else {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_unlike")!, status: NSLocalizedString("你的取消TA收到了", comment: ""))
                }
                self.loadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    SVProgressHUD.dismiss()
                }
                return
            }
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
            return
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return likeListViewModel.statusList[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel = likeListViewModel.statusList[indexPath.row]
        let vc = CommentTableViewController()
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
}
extension LikeStatusTableViewController: StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
