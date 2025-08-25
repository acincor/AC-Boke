//
//  CommentTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit

class CommentTableViewController: VisitorTableViewController {
    var commentListViewModel = TypeNeedCacheListViewModel()
    private func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 400
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        tableView.rowHeight = 400
    }
    var viewModel: StatusViewModel
    init(viewModel: StatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func loadData() {
        refreshControl?.beginRefreshing()
        //StatusDAL.clearDataCache()
        commentListViewModel.loadStatus(id: viewModel.status.id) { (isSuccessful) in
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
    lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
    override func viewDidLoad() {
        super.viewDidLoad()
        let cell = StatusNormalCell(style: .default, reuseIdentifier: StatusCellNormalId)
        cell.viewModel = viewModel
        cell.bottomView.removeFromSuperview()
        tableView.tableHeaderView = cell
        tableView.tableHeaderView?.frame = CGRectMake(cell.frame.maxX, cell.frame.maxY, cell.frame.width, viewModel.rowHeight-40)
        refreshControl = ACRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: NSLocalizedString("登陆一下，随时随地发现新鲜事", comment: ""))
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭", comment: ""), style: .plain, target: self, action: #selector(self.close))
        navigationItem.rightBarButtonItem?.tintColor = .red
        NotificationCenter.default.addObserver(forName: Notification.Name(ACStatusSelectedPhotoNotification), object: nil, queue: nil) { n in
            guard let indexPath = n.userInfo?[ACStatusSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let urls = n.userInfo?[ACStatusSelectedPhotoURLsKey] as? [URL] else {
                return
            }
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            Task { @MainActor in
                let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self.photoBrowserAnimator
                self.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
                self.present(vc, animated: true,completion: nil)
            }
        }
        loadData()
        prepareTableView()
    }
    @objc func close() {
        self.dismiss(animated: true)
    }
    @objc func whenIconViewIsTouched(sender: UITapGestureRecognizer) {
        present(UINavigationController(rootViewController: ProfileTableViewController(account: sender.userViewModel)), animated: true)
    }
    //var int = 0
}
extension CommentTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentListViewModel.statusList.count
    }
    @objc func deleteComment(_ sender: UIButton) {
        NetworkTools.shared.deleteStatus((sender.vm?.status.comment_id)!,nil,(sender.vm?.status.id)!) { Result, Error in
            
            if Error != nil {
                showError("出错了")
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                showError("不能删除别人的博客哦")
                return
            }
            showInfo("删除成功")
            Task { @MainActor in
                self.loadData()
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = commentListViewModel.statusList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusNormalCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.vm = vm
        let like_list = vm.status.like_list
        cell.bottomView.likeButton.setImage(.timelineIconUnlike, for: .normal)
        let g = UITapGestureRecognizer(target: self, action: #selector(self.whenIconViewIsTouched(sender:)))
        g.userViewModel = UserViewModel(user: Account(dict: ["user":vm.status.user ?? "","uid": "\(vm.status.comment_uid)", "portrait":vm.userProfileUrl.absoluteString]))
        cell.topView.iconView.addGestureRecognizer(g)
        for s in like_list {
            if UserAccountViewModel.sharedUserAccount.account!.uid! == s["like_uid"] as? String {
                cell.bottomView.likeButton.setImage(.timelineIconLike, for: .normal)
                break
            }
        }
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.deleteComment(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.vm = vm
        cell.bottomView.likeButton.setTitle("\(commentListViewModel.statusList[indexPath.row].status.like_count)", for: .normal)
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.like(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.compose(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = commentListViewModel.statusList[indexPath.row]
        let vc = QuoteTableViewController(vm:vm)
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        present(nav, animated: true)
    }
    @objc func compose(_ sender: UIButton) {
        let nav = ComposeViewController(sender.vm!.status.comment_id, sender.vm!.status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func like(_ sender: UIButton) {
        NetworkTools.shared.like(viewModel.status.id,commentListViewModel.statusList[sender.tag].status.comment_id) { Result, Error in
            if Error == nil {
                //sender.int = 0
                Task { @MainActor in
                    self.loadData()
                }
                //sender.setTitle("\(commentListViewModel.commentList[sender.tag].comment.like_count)", for: .normal)
                if (Result as! [String:Any])["code"] as! String == "add" {
                    showAlert(.timelineIconLike, "你的点赞TA收到了")
                    return
                }
                showAlert(.timelineIconUnlike, "你的取消TA收到了")
                return
            }
            showError("出错了")
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return commentListViewModel.statusList[indexPath.row].rowHeight
    }
}
extension CommentTableViewController: @preconcurrency StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = ACWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
