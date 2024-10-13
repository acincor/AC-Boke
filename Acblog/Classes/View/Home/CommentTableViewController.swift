//
//  CommentTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit
import SVProgressHUD



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
        commentListViewModel.loadStatus(id: viewModel.status.id) { (isSuccessed) in
            Task { @MainActor in
                self.refreshControl?.endRefreshing()
                
                if !isSuccessed {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后再试", comment: ""))
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
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: NSLocalizedString("登陆一下，随时随地发现新鲜事", comment: ""))
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭", comment: ""), style: .plain, target: self, action: #selector(self.close))
        navigationItem.rightBarButtonItem?.tintColor = .red
        NotificationCenter.default.addObserver(forName: Notification.Name(WBStatusSelectedPhotoNotification), object: nil, queue: nil) { n in
            guard let indexPath = n.userInfo?[WBStatusSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let urls = n.userInfo?[WBStatusSelectedPhotoURLsKey] as? [URL] else {
                return
            }
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            DataSaver.set(data: cell)
            Task { @MainActor in
                let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
                vc.modalPresentationStyle = .custom
                guard let cell = DataSaver.get() as? PhotoBrowserPresentDelegate else {
                    return
                }
                self.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
                vc.transitioningDelegate = self.photoBrowserAnimator
                self.present(vc, animated: true,completion: nil)
            }
        }
        NotificationCenter.default.addObserver(forName: Notification.Name("BKLikeIsTrueLightIt"), object: nil, queue: nil) { n in
            guard let o = n.object else {
                return
            }
            DataSaver.set(data: o)
            Task { @MainActor in
                if self.commentListViewModel.statusList.isEmpty {
                    return
                }
                guard let object = DataSaver.get() as? [String:Any] else {
                    return
                }
                let result = ["id":"\((object["viewModel"] as! StatusViewModel).status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
                let like_list = (object["viewModel"] as! StatusViewModel).status.like_list
                self.cell = (object["cell"] as! StatusNormalCell)
                for s in like_list {
                    if result["like_uid"] as? String == s["like_uid"] as? String {
                        
                        self.cell?.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_like"), for: .normal)
                        break
                    } else {
                        self.cell?.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
                    }
                }
                if like_list.isEmpty {
                    self.cell?.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
                }
            }
        }
        loadData()
        prepareTableView()
    }
    
    var cell: StatusNormalCell?
    @objc func close() {
        self.dismiss(animated: true)
    }
    //var int = 0
}
extension CommentTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentListViewModel.statusList.count
    }
    @objc func action(_ sender: UIButton) {
        NetworkTools.shared.deleteStatus((sender.vm?.status.comment_id)!,nil,(sender.vm?.status.id)!) { Result, Error in
            
            if Error != nil {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                }
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("不能删除别人的博客哦", comment: ""))
                }
                return
            }
            Task { @MainActor in
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("删除成功", comment: ""))
            }
            Task { @MainActor in
                self.loadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = commentListViewModel.statusList[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusNormalCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.vm = vm
        NotificationCenter.default.post(name: Notification.Name("BKLikeIsTrueLightIt"), object: ["cell":cell,"viewModel":vm] as [String : Any])
        cell = self.cell!
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.vm = vm
        
        cell.bottomView.likeButton.setTitle("\(commentListViewModel.statusList[indexPath.row].status.like_count)", for: .normal)
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
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
    @objc func action3(_ sender: UIButton) {
        let nav = ComposeViewController(sender.vm!.status.comment_id, sender.vm!.status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.like(viewModel.status.id,commentListViewModel.statusList[sender.tag].status.comment_id) { Result, Error in
            
            if Error == nil {
                //sender.int = 0
                if (Result as! [String:Any])["code"] as! String == "add" {
                    Task { @MainActor in
                        SVProgressHUD.show(UIImage(named: "timeline_icon_like")!, status: NSLocalizedString("你的点赞TA收到了", comment: ""))
                    }
                } else {
                    Task { @MainActor in
                        SVProgressHUD.show(UIImage(named: "timeline_icon_unlike")!, status: NSLocalizedString("你的取消TA收到了", comment: ""))
                    }
                }
                Task { @MainActor in
                    self.loadData()
                }
                
                //sender.setTitle("\(commentListViewModel.commentList[sender.tag].comment.like_count)", for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    SVProgressHUD.dismiss()
                }
                return
                
            } else {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                }
                return
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return commentListViewModel.statusList[indexPath.row].rowHeight
    }
}
extension CommentTableViewController: @preconcurrency StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
