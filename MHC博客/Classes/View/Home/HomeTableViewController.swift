//
//  HomeTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit


let StatusCellNormalId = "StatusCellNormalId"
let StatusCellNormalId2 = "StatusCellNormalId2"
var listViewModel = StatusListViewModel()
class HomeTableViewController: VisitorTableViewController {
    private lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .white
        return indicator
    }()
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId2)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = 400
        refreshControl = WBRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        tableView.tableFooterView = pullupView
    }
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        //print(self.pullupView.isAnimating)
        StatusDAL.clearDataCache()
        listViewModel.loadStatus(isPullup: pullupView.isAnimating) { (isSuccessed) in
            self.refreshControl?.endRefreshing()
            self.pullupView.stopAnimating()
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
            //print(listViewModel.statusList)
            self.showPulldownTip()
            self.tableView.reloadData()
        }
    }
    private lazy var pulldownTipLabel: UILabel = {
        let label = UILabel(title: "", fontSize: 18,color: .white)
        label.backgroundColor = .orange
        self.navigationController?.navigationBar.insertSubview(label, at: 0)
        return label
    }()
    private func showPulldownTip() {
        guard let count = listViewModel.pulldownCount else {
            //print("难道你有博客吗？")
            return
        }
        //print("count:",count)
        pulldownTipLabel.text = (count == 0) ? "没有博客" : "刷新到\(count)条博客"
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
            visitorView?.setupInfo(imageName: nil, title: "关注一些人，回这里看看有什么惊喜")
            return
        }
        
        loadData()
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
        NotificationCenter.default.addObserver(forName: Notification.Name("BKIfLikeIsTrueLightIt"), object: nil, queue: nil) { n in
            if n.object != nil {
                let result = ["id":"\(listViewModel.statusList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
                let like_list = listViewModel.statusList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.like_list
                self.cell = ((n.object as! [String:Any])["cell"] as! StatusCell)
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
            if n.userInfo != nil {
                if n.userInfo!.isEqualTo(["hello":"l"]) {
                    let result = ["id":"\(listViewModel.statusList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
                    let like_list = listViewModel.statusList[((n.object as! [String:Any])["indexPath"] as! IndexPath).row].status.like_list
                    discover.cell = ((n.object as! [String:Any])["cell"] as! StatusNormalCell)
                    for s in like_list {
                        if result.isEqualTo(s) {
                            
                            discover.cell?.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_like"), for: .normal)
                            break
                        } else {
                            discover.cell?.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
                        }
                    }
                    if like_list.isEmpty {
                        discover.cell?.bottomView.likeButton.setImage(UIImage(named:"timeline_icon_unlike"), for: .normal)
                    }
                }
            }
        }
    }
    var cell: StatusCell?
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
}
extension HomeTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = listViewModel.statusList[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.identifier = cell
        cell.bottomView.deleteButton.tag = indexPath.row
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        /*
        cell.bottomView.deleteButton.addAction(UIAction { action in
            cell.bottomView.deleteBlog(listViewModel.statusList[indexPath.row].status.id) { Result, Error in
                //print(listViewModel.statusList[indexPath.row].status.id)
                //print(UserAccountViewModel.sharedUserAccount.accessToken)
                if Error != nil {
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
                if (Result as! [String:Any])["error"] != nil {
                    SVProgressHUD.showInfo(withStatus: "不能删除别人的博客哦")
                    //print((Result as! [String:String])["error"])
                    return
                }
                SVProgressHUD.showInfo(withStatus: "删除成功")
            }
        }, for: .touchUpInside)
         */
        cell.bottomView.commentButton.setTitle("\(listViewModel.statusList[indexPath.row].status.comment_count)", for: .normal)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.setTitle("\(listViewModel.statusList[indexPath.row].status.like_count)", for: .normal)
        NotificationCenter.default.post(name: Notification.Name("BKIfLikeIsTrueLightIt"), object: ["cell":cell,"indexPath":indexPath])
        cell = self.cell!
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    @objc func action2(_ sender: UIButton) {
        NetworkTools.shared.addComment(id: listViewModel.statusList[sender.tag].status.id, sender.nav.textView.emoticonText) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print(Error)
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print(Error)
                return
            }
            sender.nav.close()
        }
    }
    @objc func action1(_ sender: UIButton) {
        sender.identifier.bottomView.deleteBlog(listViewModel.statusList[sender.tag].status.id) { Result, Error in
            //print(listViewModel.statusList[indexPath.row].status.id)
            //print(UserAccountViewModel.sharedUserAccount.accessToken)
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                print(Error)
                return
            }
            print(Result as! [String:Any])
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: "不能删除别人的博客哦")
                //print((Result as! [String:String])["error"])
                return
            }
            SVProgressHUD.showInfo(withStatus: "删除成功")
            self.loadData()
        }
    }
    @objc func action3(_ sender: UIButton) {
        let nav = CommentViewController()
        let button = UIButton(title: "发表", color: .orange,backImageName: nil)
        //print(listViewModel.statusList[indexPath.row].status.id)
        //print(nav.textView.text!)
        guard (listViewModel.statusList[sender.tag].status.id > 0) else {
            SVProgressHUD.showInfo(withStatus: "出错了")
            return
        }
        button.nav = nav
        button.tag = sender.tag
        button.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        if sender.int == 1 {
            //print(id ?? 0)
            NetworkTools.shared.deleteLike(listViewModel.statusList[sender.tag].status.id) { Result, Error in
                if Error == nil {
                    //print(Result as! [String:Any])
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
                NetworkTools.shared.addLike(listViewModel.statusList[sender.tag].status.id) { Result, Error in
                    if Error == nil {
                        //print(Result as! [String:Any])
                        
                        sender.int = 1
                        self.loadData()
                        return
                    }
                    SVProgressHUD.showInfo(withStatus: "出错了")
                    //print(Error)
                    return
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listViewModel.statusList[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        id = indexPath.row
        let vc = CommentTableViewController()
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
}
extension HomeTableViewController: StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension Dictionary where Key: Equatable {
    func isEqualTo(_ dictionary: Dictionary, excluding: [Key] = []) -> Bool {
      let left = filter({ !excluding.contains($0.key) })
      let right = dictionary.filter({ !excluding.contains($0.key) })
      return NSDictionary(dictionary: left).isEqual(to: right)
    }
}
extension UITextField {
    private struct AssociatedKey {
        static var identifier = ""
    }
    var identifier: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.identifier) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.identifier, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
extension UIButton {
    private struct AssociatedKey {
           static var identifier: StatusCell = StatusCell()
        static var cell: CommentCell = CommentCell()
        static var cell2: CommentCommentCell = CommentCommentCell()
        static var nav: CommentViewController = CommentViewController()
        static var int: Int = 0
        static var vm: CommentViewModel? = CommentListViewModel().commentList.first
        static var vm2: CommentCommentViewModel? = CommentListViewModel().commentCommentList.first
       }
       
       var identifier: StatusCell {
           get {
               return objc_getAssociatedObject(self, &AssociatedKey.identifier) as? StatusCell ?? StatusCell()
           }
           set {
               objc_setAssociatedObject(self, &AssociatedKey.identifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
           }
       }
    var cell: CommentCell {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cell) as? CommentCell ?? CommentCell()
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cell, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    var cell2: CommentCommentCell {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cell2) as? CommentCommentCell ?? CommentCommentCell()
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cell2, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    var vm: CommentViewModel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.vm) as? CommentViewModel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.vm, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var vm2: CommentCommentViewModel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.vm2) as? CommentCommentViewModel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.vm2, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var nav: CommentViewController {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.nav) as? CommentViewController ?? CommentViewController()
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.nav, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var int: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.int) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.int, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
