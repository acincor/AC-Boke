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
        if sender.int == 1 {
            //print(id ?? 0)
            NetworkTools.shared.deleteLike(listViewModel.statusList[sender.tag].status.id,comment_id: commentlistViewModel.commentCommentList[sender.tag].comment.comment_id,commentlistViewModel.commentList[sender.tag].comment.comment_id) { Result, Error in
                if Error == nil {
                    print(Result)
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
                print(comment_id)
                NetworkTools.shared.addLike(listViewModel.statusList[sender.tag].status.id,commentlistViewModel.commentList[sender.tag].comment.comment_id,comment_id:commentlistViewModel.commentCommentList[sender.tag].comment.comment_id) { Result, Error in
                    if Error == nil {
                        print(Result as! [String:Any])
                        sender.int = 1
                        self.loadData()
                        return
                    }
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    print(Error)
                    return
                }
            }
        }
    }
    @objc func loadData() {
        guard let id = comment_id else{
            return
        }
        guard let comment_id = comment_comment_id else{
            return
        }
        print([id,comment_id])
        refreshControl?.beginRefreshing()
        StatusDAL.clearDataCache()
        commentlistViewModel.loadComment(id: id, comment_id: comment_id) { (isSuccessed) in
            self.refreshControl?.endRefreshing()
             if !isSuccessed {
                 SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                 return
             }
             //print("array,",self.commentlistViewModel.commentList)
             self.tableView.reloadData()
         }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: "关注一些人，回这里看看有什么惊喜")
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
                    if result.isEqualTo(s) {
                        
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
        //print("loadData")
        prepareTableView()
        guard let id = id else {
            return
        }
        let cell = CommentCell(style: .default, reuseIdentifier: CommentCellNormalId)
        cell.viewModel = commentlistViewModel.commentList[id]
        cell.bottomView.removeFromSuperview()
        tableView.tableHeaderView = cell
        tableView.tableHeaderView?.frame = CGRectMake(cell.frame.maxX, cell.frame.maxY, cell.frame.width, listViewModel.statusList[id].rowHeight-40)
        
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
}
extension CommentCommentTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentlistViewModel.commentCommentList.count
    }
    /*
    @objc func action(_ sender: UIButton) {
        NetworkTools.shared.deleteComment((sender.vm?.comment.id)!, (sender.vm?.comment.comment_id)!) { Result, Error in
            //print(UserAccountViewModel.sharedUserAccount.accessToken)
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print(Error)
                return
            }
            ////print(Result)
            if (Result as! [String:String])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: "不能删除别人的博客哦")
                //print((Result as! [String:String])["error"])
                return
            }
            ////print(Result)
            SVProgressHUD.showInfo(withStatus: "删除成功")
        }
    }
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = commentlistViewModel.commentCommentList[indexPath.row]
        //print("vm,",vm)
        var cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! CommentCommentCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.vm2 = vm
        NotificationCenter.default.post(name: Notification.Name("BKLikeLightIt"), object: ["cell":cell,"indexPath":indexPath])
        cell = self.cell!
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.setTitle("\(commentlistViewModel.commentCommentList[indexPath.row].comment.like_count)", for: .normal)
        cell.bottomView.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        /*
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.vm2 = vm
        cell.bottomView.commentButton.cell2 = cell
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
         */
        return cell
    }
    @objc func action3(_ sender: UIButton) {
        let nav = CommentViewController()
        let button = UIButton(title: "发表", color: .red,backImageName: nil)
        button.tag = sender.tag
        button.nav = nav
        button.vm2 = sender.vm2
        button.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        sender.cell2.cellDelegate = self
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.deleteComment(sender.vm2!.comment.id,  comment_comment_id! , comment_id: sender.vm2!.comment.comment_id) { Result, Error in
            
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
                //print(Result)
                if (Result as! [String:String])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
            sender.nav.close()
            }
    }
    @objc func action2(_ sender: UIButton) {
        guard (commentlistViewModel.commentCommentList[sender.tag].comment.comment_id > 0) else {
            sender.nav.close()
            SVProgressHUD.showInfo(withStatus: "出错了")
            return
        }
        NetworkTools.shared.addComment(id: sender.vm2!.comment.id, comment_id: sender.vm2!.comment.comment_id, sender.nav.textView.text!) { Result, Error in
            
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
                //print(Result)
                if (Result as! [String:Int])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
            sender.nav.close()
            }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return commentlistViewModel.commentCommentList[indexPath.row].rowHeight
    }
}
extension CommentCommentTableViewController: CommentCommentCellDelegate {
    func commentCommentCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
