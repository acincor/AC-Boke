//
//  BlogsTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit
import SwiftUI


//let StatusCellNormalId2 = "StatusCellNormalId2"

class BlogsTableViewController: VisitorTableViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    var list = [StatusViewModel]()
    var uid: String
    init(uid: String) {
        self.uid = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    let liveView = LiveTableView()
    private func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        //tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId2)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = 400
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        liveView.delegate = self
        liveView.dataSource = self
        tableView.tableHeaderView = liveListViewModel.liveList.isEmpty ? nil : liveView
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liveListViewModel.liveList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vm = liveListViewModel.liveList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveCellNormalId, for: indexPath) as! UserCollectionCell
        cell.viewModel = vm
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vm = liveListViewModel.liveList[indexPath.row]
        guard let url = ("http://localhost/hls/\(vm.user.uid).m3u8").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("似乎出了点问题，请刷新重试", comment: ""))
            return
        }
        print(url)
        guard let urlEncoded = URL(string:url) else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("似乎出了点问题，请刷新重试", comment: ""))
            return
        }
        present(HomeWebViewController(url: urlEncoded),animated: true)
    }
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        //StatusDAL.clearDataCache()//删除缓存
        NetworkTools.shared.profile(uid: uid) { (Result,Error) in
            self.refreshControl?.endRefreshing()
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后重试", comment: ""))
                return
            }
            guard let res = Result as? [[String:Any]] else{
                return
            }
            var dataList = [StatusViewModel]()
            for i in res {
                dataList.append(StatusViewModel(status: Status(dict: i)))
            }
            self.list = dataList
            self.showPulldownTip()
            self.tableView.reloadData()
        }
            self.liveView.loadData()
            self.liveView.reloadData()
            self.tableView.tableHeaderView = liveListViewModel.liveList.isEmpty ? nil : self.liveView
    }
    private lazy var pulldownTipLabel: UILabel = {
        let label = UILabel(title: "", fontSize: 18,color: .white)
        label.backgroundColor = .red
        self.navigationController?.navigationBar.insertSubview(label, at: 0)
        return label
    }()
    private func showPulldownTip() {
        guard let count = listViewModel.pulldownCount else {
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
        prepareTableView()
        NotificationCenter.default.addObserver(forName: Notification.Name(WBStatusSelectedPhotoNotification), object: nil, queue: nil) {[weak self] n in
            guard let indexPath = n.userInfo?[WBStatusSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let urls = n.userInfo?[WBStatusSelectedPhotoURLsKey] as? [URL] else {
                return
            }
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self?.photoBrowserAnimator
            self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
            self?.present(vc, animated: true,completion: nil)
        }
        self.loadData()
    }
    @objc func action(sender: UITapGestureRecognizer) {
        let dict = ["portrait": sender.sender3, "user": sender.sender2, "uid": sender.sender]
        let uvm = UserViewModel(user: Account(dict: dict))
        present(UINavigationController(rootViewController: UIHostingController(rootView: UserNavigationLinkView(account: uvm, uid: sender.sender))), animated: true)
        }

    var cell: StatusCell?
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
}
extension BlogsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusCell
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
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        let result = ["id":"\(list[indexPath.row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
        cell.bottomView.likeButton.setTitle("\(list[indexPath.row].status.like_count)", for: .normal)
        NetworkTools.shared.loadOneStatus(id: list[indexPath.row].status.id) { res, error in
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
    @objc func action2(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: NSLocalizedString("加载中", comment: ""))
        NetworkTools.shared.addComment(id: list[sender.tag].status.id, sender.nav.textView.emoticonText) { Result, Error in
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
            self.tableView.reloadData()
        }
    }
    @objc func action1(_ sender: UIButton) {
        sender.identifier.bottomView.deleteBlog(list[sender.tag].status.id) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("不能删除别人的博客哦", comment: ""))
                return
            }
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("删除成功", comment: ""))
            StatusDAL.removeCache(self.list[sender.tag].status.id)
            self.list.remove(at: sender.tag)
            self.tableView.reloadData()
        }
    }
    @objc func action3(_ sender: UIButton) {
        let nav = CommentViewController()
        let button = UIButton(title: NSLocalizedString("发布", comment: ""), color: .red,backImageName: nil)
        guard (list[sender.tag].status.id > 0) else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
            return
        }
        button.nav = nav
        button.tag = sender.tag
        button.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.like(list[sender.tag].status.id) { Result, Error in
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return list[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel = list[indexPath.row]
        let vc = CommentTableViewController()
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
}
extension BlogsTableViewController: StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
