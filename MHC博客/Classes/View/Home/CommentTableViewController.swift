//
//  HomeTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit



class CommentTableViewController: VisitorTableViewController {
    private func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 400
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        tableView.rowHeight = 400
    }
    
    @objc func loadData() {
        guard let viewModel = viewModel else{
            return
        }
        refreshControl?.beginRefreshing()
        //StatusDAL.clearDataCache()
        commentlistViewModel.loadComment(id: viewModel.status.id) { (isSuccessed) in
             self.refreshControl?.endRefreshing()
             if !isSuccessed {
                 SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后再试", comment: ""))
                 return
             }
             self.tableView.reloadData()
         }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else{
            return
        }
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
        NotificationCenter.default.addObserver(forName: Notification.Name("BKLikeIsTrueLightIt"), object: nil, queue: nil) { n in
            if commentlistViewModel.commentList.isEmpty {
                return
            }
            
                if n.object != nil {
                    let result = ["id":"\(commentlistViewModel.commentList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
                    let like_list = commentlistViewModel.commentList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.like_list
                    self.cell = ((n.object as! [String:Any])["cell"] as! StatusNormalCell)
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
        return commentlistViewModel.commentList.count
    }
    @objc func action(_ sender: UIButton) {
        NetworkTools.shared.deleteStatus((sender.vm?.status.comment_id)!,nil,(sender.vm?.status.id)!) { Result, Error in
            
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
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = commentlistViewModel.commentList[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusNormalCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.vm = vm
        NotificationCenter.default.post(name: Notification.Name("BKLikeIsTrueLightIt"), object: ["cell":cell,"indexPath":indexPath] as [String : Any])
        cell = self.cell!
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.vm = vm
        
        cell.bottomView.likeButton.setTitle("\(commentlistViewModel.commentList[indexPath.row].status.like_count)", for: .normal)
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = commentlistViewModel.commentList[indexPath.row]
        let vc = CommentCommentTableViewController(id: indexPath.row, comment_id: vm.status.id, comment_comment_id: vm.status.comment_id)
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        present(nav, animated: true)
    }
    @objc func action3(_ sender: UIButton) {
        let nav = ComposeViewController(sender.vm!.status.comment_id, sender.vm!.status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.like((viewModel?.status.id)!,commentlistViewModel.commentList[sender.tag].status.comment_id) { Result, Error in
            if Error == nil {
                //sender.int = 0
                if (Result as! [String:Any])["code"] as! String == "add" {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_like")!, status: NSLocalizedString("你的点赞TA收到了", comment: ""))
                } else {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_unlike")!, status: NSLocalizedString("你的取消TA收到了", comment: ""))
                }
                self.loadData()
                //sender.setTitle("\(commentlistViewModel.commentList[sender.tag].comment.like_count)", for: .normal)
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
        return commentlistViewModel.commentList[indexPath.row].rowHeight
    }
}
extension CommentTableViewController: StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
