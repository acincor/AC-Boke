//
//  QuoteTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit
import SVProgressHUD

class QuoteTableViewController: VisitorTableViewController {
    var commentlistViewModel = TypeNeedCacheListViewModel()
    var vm: StatusViewModel
    init(vm: StatusViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = 400
    }
    @objc func action5(_ sender: UIButton) {
        NetworkTools.shared.like(vm.status.id,comment_id: commentlistViewModel.statusList[sender.tag].status.comment_id,vm.status.comment_id) { Result, Error in
            if Error == nil {
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
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    SVProgressHUD.dismiss()
                }
                return
            }
            Task { @MainActor in
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
            }
            return
        }
    }
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        commentlistViewModel.loadStatus(id: vm.status.id, comment_id: vm.status.comment_id) { (isSuccessed) in
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
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: NSLocalizedString("登陆一下，随时随地发现新鲜事", comment: ""))
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭", comment: ""), style: .plain, target: self, action: #selector(self.close))
        navigationItem.rightBarButtonItem?.tintColor = .red
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
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
            Task { @MainActor in
                let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self?.photoBrowserAnimator
                self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
                self?.present(vc, animated: true,completion: nil)
            }
        }
        loadData()
        prepareTableView()
        let cell = StatusNormalCell(style: .default, reuseIdentifier: StatusCellNormalId)
        cell.viewModel = vm
        cell.bottomView.removeFromSuperview()
        tableView.tableHeaderView = cell
        tableView.tableHeaderView?.frame = CGRectMake(cell.frame.maxX, cell.frame.maxY, cell.frame.width, vm.rowHeight-40)
        
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
}
extension QuoteTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentlistViewModel.statusList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = commentlistViewModel.statusList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusNormalCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.vm2 = vm
        let result = ["id":"\(vm.status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
        let like_list = vm.status.like_list
        for s in like_list {
            if s["like_uid"] as! String == result["like_uid"] as! String {
                
                cell.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_like"), for: .normal)
                break
            } else {
                cell.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
            }
        }
        if like_list.isEmpty {
            cell.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
        }
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.setTitle("\(commentlistViewModel.statusList[indexPath.row].status.like_count)", for: .normal)
        cell.bottomView.likeButton.tag = indexPath.row
        //action5(cell.commentBottomView.likeButton)
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        /*
         cell.bottomView.commentButton.tag = indexPath.row
         cell.bottomView.commentButton.vm2 = vm
         cell.bottomView.commentButton.cell2 = cell
         cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
         */
        cell.bottomView.likeButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(cell.bottomView.deleteButton.snp.top)
            make.left.equalTo(cell.bottomView.deleteButton.snp.right)
            make.width.equalTo(cell.bottomView.deleteButton.snp.width)
            make.height.equalTo(cell.bottomView.deleteButton.snp.height)
            make.right.equalTo(cell.bottomView.snp.right)
        }
        cell.bottomView.commentButton.removeFromSuperview()
        return cell
    }
    /*
     @objc func action3(_ sender: UIButton) {
     let nav = CommentViewController()
     let button = UIButton(title: "发布", color: .red,backImageName: nil)
     button.tag = sender.tag
     button.nav = nav
     button.vm2 = sender.vm2
     button.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
     sender.cell2.cellDelegate = self
     nav.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
     self.present(UINavigationController(rootViewController: nav), animated: true)
     }
     */
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.deleteStatus(vm.status.comment_id,sender.vm2!.status.comment_id,sender.vm2!.status.id) { Result, Error in
            if Error != nil {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                }
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return commentlistViewModel.statusList[indexPath.row].rowHeight
    }
}
extension QuoteTableViewController: @preconcurrency StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
