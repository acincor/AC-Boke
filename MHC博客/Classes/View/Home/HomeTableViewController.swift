//
//  HomeTableViewController.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import UIKit
import SwiftUI


let StatusCellNormalId = "StatusCellNormalId"
//let StatusCellNormalId2 = "StatusCellNormalId2"

var viewModel: StatusViewModel?
class HomeTableViewController: VisitorTableViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    private lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemBackground
        return indicator
    }()
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
        tableView.tableFooterView = pullupView
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
            SVProgressHUD.showInfo(withStatus: "似乎出了点问题，请刷新重试")
            return
        }
        print(url)
        guard let urlEncoded = URL(string:url) else {
            SVProgressHUD.showInfo(withStatus: "似乎出了点问题，请刷新重试")
            return
        }
        present(HomeWebViewController(url: urlEncoded),animated: true)
    }
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        //StatusDAL.clearDataCache()//删除缓存
        listViewModel.loadStatus(isPullup: self.pullupView.isAnimating) { (isSuccessed) in
            self.refreshControl?.endRefreshing()
            self.pullupView.stopAnimating()
            if !isSuccessed {
                SVProgressHUD.showInfo(withStatus: "加载数据错误，请稍后再试")
                return
            }
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
        present(UINavigationController(rootViewController: UIHostingController(rootView: UserNavigationLinkView(account: uvm))), animated: true)
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
        let g = UITapGestureRecognizer(target: self, action: #selector(self.action(sender:)))
        guard let viewModel = cell.topView.viewModel as? StatusViewModel else {
            return cell
        }
        g.sender = "\(viewModel.status.uid)"
        g.sender2 = "\(viewModel.status.user ?? "")"
        g.sender3 = "\(viewModel.status.portrait ?? "")"
        cell.topView.iconView.addGestureRecognizer(g)
        if listViewModel.statusList.count % 10 == 0 {
            if indexPath.row == listViewModel.statusList.count - 1 && !pullupView.isAnimating {
                // 开始动画
                pullupView.startAnimating()
                loadData()
            }//十条刷新一次
        }
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        let result = ["id":"\(listViewModel.statusList[indexPath.row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
        cell.bottomView.likeButton.setTitle("\(listViewModel.statusList[indexPath.row].status.like_count)", for: .normal)
        NetworkTools.shared.loadOneStatus(id: listViewModel.statusList[indexPath.row].status.id) { res, error in
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
        SVProgressHUD.show(withStatus: "加载中")
        NetworkTools.shared.addComment(id: listViewModel.statusList[sender.tag].status.id, sender.nav.textView.emoticonText) { Result, Error in
            SVProgressHUD.dismiss()
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                return
            }
            sender.nav.close()
            self.tableView.reloadData()
        }
    }
    @objc func action1(_ sender: UIButton) {
        sender.identifier.bottomView.deleteBlog(listViewModel.statusList[sender.tag].status.id) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                SVProgressHUD.showInfo(withStatus: "不能删除别人的博客哦")
                return
            }
            SVProgressHUD.showInfo(withStatus: "删除成功")
            StatusDAL.removeCache(listViewModel.statusList[sender.tag].status.id)
            listViewModel.statusList.remove(at: sender.tag)
            self.tableView.reloadData()
        }
    }
    @objc func action3(_ sender: UIButton) {
        let nav = CommentViewController()
        let button = UIButton(title: "发布", color: .red,backImageName: nil)
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
        NetworkTools.shared.like(listViewModel.statusList[sender.tag].status.id) { Result, Error in
            if Error == nil {
                if (Result as! [String:Any])["code"] as! String == "add" {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_like")!, status: "你的点赞TA收到了")
                } else {
                    SVProgressHUD.show(UIImage(named: "timeline_icon_unlike")!, status: "你的取消TA收到了")
                }
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    SVProgressHUD.dismiss()
                }
                return
            }
            SVProgressHUD.showInfo(withStatus: "出错了")
            return
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listViewModel.statusList[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel = listViewModel.statusList[indexPath.row]
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
        static var cell: StatusCommentCell = StatusCommentCell()
        static var cell2: CommentCommentCell = CommentCommentCell()
        static var nav: CommentViewController = CommentViewController()
        static var int: Int = 0
        static var vm: CommentViewModel? = CommentListViewModel().commentList.first
        static var vm2: CommentViewModel? = CommentListViewModel().commentCommentList.first
       }
       
       var identifier: StatusCell {
           get {
               return objc_getAssociatedObject(self, &AssociatedKey.identifier) as? StatusCell ?? StatusCell()
           }
           set {
               objc_setAssociatedObject(self, &AssociatedKey.identifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
           }
       }
    var cell: StatusCommentCell {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cell) as? StatusCommentCell ?? StatusCommentCell()
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
    var vm2: CommentViewModel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.vm2) as? CommentViewModel
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
