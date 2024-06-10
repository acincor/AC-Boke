//
//  HomeTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit

var commentlistViewModel = CommentListViewModel()
class CommentCommentTableViewController: VisitorTableViewController {
    var cell: StatusNormalCell?
    var comment_id: Int
    var id: Int
    var comment_comment_id: Int
    init(id: Int,comment_id: Int, comment_comment_id: Int) {
        self.id = id
        self.comment_id = comment_id
        self.comment_comment_id = comment_comment_id
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
        NetworkTools.shared.like(comment_id,comment_id: commentlistViewModel.commentCommentList[sender.tag].status.comment_id,comment_comment_id) { Result, Error in
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
    @objc func loadData() {
            self.refreshControl?.beginRefreshing()
            commentlistViewModel.loadComment(id: comment_id, comment_id: comment_comment_id) { (isSuccessed) in
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
        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(imageName: nil, title: NSLocalizedString("登陆一下，随时随地发现新鲜事", comment: ""))
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭", comment: ""), style: .plain, target: self, action: #selector(self.close))
        navigationItem.rightBarButtonItem?.tintColor = .red
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        NotificationCenter.default.addObserver(forName: Notification.Name("BKLikeLightIt"), object: nil, queue: nil) { n in
            if n.object != nil {
                let result = ["id":"\(commentlistViewModel.commentCommentList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
                let like_list = commentlistViewModel.commentCommentList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.like_list
                self.cell = ((n.object as! [String:Any])["cell"] as! StatusNormalCell)
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
        let cell = StatusNormalCell(style: .default, reuseIdentifier: StatusCellNormalId)
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
        var cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusNormalCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.vm2 = vm
        NotificationCenter.default.post(name: Notification.Name("BKLikeLightIt"), object: ["cell":cell,"indexPath":indexPath] as [String : Any])
        cell = self.cell!
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.setTitle("\(commentlistViewModel.commentCommentList[indexPath.row].status.like_count)", for: .normal)
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
        NetworkTools.shared.deleteStatus(comment_comment_id,sender.vm2!.status.comment_id,sender.vm2!.status.id) { Result, Error in
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                    return
                }
                if (Result as! [String:Any])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                    return
                }
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("删除成功", comment: ""))
            self.loadData()
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
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
