//
//  HomeTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit


let CommentCommentCellNormalId = "CommentCommentCellNormalId"
var comment_id: Int?
var comment_comment_id: Int?
var commentlistViewModel = CommentListViewModel()
class CommentCommentTableViewController: VisitorTableViewController {
    var cell: CommentCommentCell?
    private func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.register(CommentCommentCell.self, forCellReuseIdentifier: CommentCommentCellNormalId)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = 400
    }
    @objc func action5(_ sender: UIButton) {
        NetworkTools.shared.like(comment_id!,comment_id: commentlistViewModel.commentCommentList[sender.tag].comment.comment_id,comment_comment_id!) { Result, Error in
            if Error == nil {
                if (Result as! [String:Any])["code"] as! String == "add" {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_like")!, status: "你的点赞TA收到了")
                } else {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_unlike")!, status: "你的取消TA收到了")
                }
                self.loadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    SVProgressHUD.dismiss()
                }
                return
            }
            SVProgressHUD.showInfo(withStatus: "出错了")
            return
        }
    }
    @objc func loadData() {
        guard let id = comment_id else{
            return
        }
        guard let comment_id = comment_comment_id else{
            return
        }
            self.refreshControl?.beginRefreshing()
            commentlistViewModel.loadComment(id: id, comment_id: comment_id) { (isSuccessed) in
                self.refreshControl?.endRefreshing()
                if !isSuccessed {
                    SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                    return
                }
                self.tableView.reloadData()
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: "登陆一下，随时随地发现新鲜事")
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(self.close))
        navigationItem.rightBarButtonItem?.tintColor = .red
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        NotificationCenter.default.addObserver(forName: Notification.Name("BKLikeLightIt"), object: nil, queue: nil) { n in
            if n.object != nil {
                let result = ["id":"\(commentlistViewModel.commentCommentList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].comment.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
                let like_list = commentlistViewModel.commentCommentList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].comment.like_list
                self.cell = ((n.object as! [String:Any])["cell"] as! CommentCommentCell)
                for s in like_list {
                    if s["like_uid"] as! String == result["like_uid"] as! String {
                        
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
        guard let id = id else {
            return
        }
        let cell = StatusCommentCell(style: .default, reuseIdentifier: CommentCellNormalId)
        cell.viewModel = commentlistViewModel.commentList[id]
        cell.bottomView.removeFromSuperview()
        tableView.tableHeaderView = cell
        tableView.tableHeaderView?.frame = CGRectMake(cell.frame.maxX, cell.frame.maxY, cell.frame.width, commentlistViewModel.commentList[id].rowHeight-40)
        
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
}
extension CommentCommentTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentlistViewModel.commentCommentList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = commentlistViewModel.commentCommentList[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! CommentCommentCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.vm2 = vm
        NotificationCenter.default.post(name: Notification.Name("BKLikeLightIt"), object: ["cell":cell,"indexPath":indexPath] as [String : Any])
        cell = self.cell!
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.setTitle("\(commentlistViewModel.commentCommentList[indexPath.row].comment.like_count)", for: .normal)
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
        NetworkTools.shared.deleteComment(sender.vm2!.comment.id,  comment_comment_id! , comment_id: sender.vm2!.comment.comment_id) { Result, Error in
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    return
                }
                if (Result as! [String:Any])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    return
                }
            SVProgressHUD.showInfo(withStatus: "删除成功")
            self.loadData()
            }
    }
    @objc func action2(_ sender: UIButton) {
        guard (commentlistViewModel.commentCommentList[sender.tag].comment.comment_id > 0) else {
            sender.nav.close()
            SVProgressHUD.showInfo(withStatus: "出错了")
            return
        }
        SVProgressHUD.show(withStatus: "加载中")
        NetworkTools.shared.addComment(id: sender.vm2!.comment.id, comment_id: sender.vm2!.comment.comment_id, sender.nav.textView.emoticonText) { Result, Error in
            SVProgressHUD.dismiss()
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    return
                }
                if (Result as! [String:Int])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    return
                }
            sender.nav.close()
            }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return commentlistViewModel.commentCommentList[indexPath.row].rowHeight
    }
}
extension CommentCommentTableViewController: StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
