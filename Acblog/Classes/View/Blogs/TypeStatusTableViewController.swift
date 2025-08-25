//
//  TypeStatusTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit
import SwiftUI


//let StatusCellNormalId2 = "StatusCellNormalId2"

class TypeStatusTableViewController: VisitorTableViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    var typeStatus: TypeStatusListViewModel
    var uid: String
    init(uid: String, clas: Clas) {
        self.uid = uid
        self.typeStatus = TypeStatusListViewModel(clas: clas)
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
        refreshControl = ACRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        liveView.delegate = self
        liveView.dataSource = self
        tableView.tableHeaderView = liveListViewModel.list.isEmpty ? nil : liveView
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liveListViewModel.list.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vm = liveListViewModel.list[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveCellNormalId, for: indexPath) as! UserCollectionCell
        cell.viewModel = vm
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vm = liveListViewModel.list[indexPath.row]
        guard let url = (rootHost+"/hls/\(vm.user.uid).m3u8").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            showError("似乎出了点问题，请刷新重试")
            return
        }
        guard let urlEncoded = URL(string:url) else {
            showError("似乎出了点问题，请刷新重试")
            return
        }
        present(ACWebViewController(url: urlEncoded),animated: true)
    }
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        //StatusDAL.clearDataCache()//删除缓存
        typeStatus.loadStatus(uid) { isSuccessful in
            Task { @MainActor in
                self.refreshControl?.endRefreshing()
                if !isSuccessful {
                    showError("加载数据错误，请稍后重试")
                    return
                }
                self.showPulldownTip()
                self.tableView.reloadData()
            }
        }
        
        self.liveView.loadData()
        self.liveView.reloadData()
        self.tableView.tableHeaderView = liveListViewModel.list.isEmpty ? nil : self.liveView
    }
    private lazy var pulldownTipLabel: UILabel = {
        let label = UILabel(title: "", fontSize: 18,color: .white)
        label.backgroundColor = .red
        self.navigationController?.navigationBar.insertSubview(label, at: 0)
        return label
    }()
    private func showPulldownTip() {
        guard let count = typeStatus.pulldownCount else {
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
        NotificationCenter.default.addObserver(forName: Notification.Name(ACStatusSelectedPhotoNotification), object: nil, queue: nil) {[weak self] n in
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
                vc.transitioningDelegate = self?.photoBrowserAnimator
                self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
                self?.present(vc, animated: true,completion: nil)
            }
        }
        self.loadData()
    }
    @objc func whenIconViewIsTouched(sender: UITapGestureRecognizer) {
        present(UINavigationController(rootViewController: ProfileTableViewController(account: sender.userViewModel)), animated: true)
    }
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
}
extension TypeStatusTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeStatus.statusList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = typeStatus.statusList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.cellId, for: indexPath) as! StatusCell
        // Configure the cell...
        cell.viewModel = vm
        cell.bottomView.deleteButton.tag = indexPath.row
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.deleteBlog(_:)), for: .touchUpInside)
        let g = UITapGestureRecognizer(target: self, action: #selector(self.whenIconViewIsTouched(sender:)))
        g.userViewModel = UserViewModel(user: Account(dict: ["user":vm.status.user ?? "","uid": "\(vm.status.uid)", "portrait":vm.userProfileUrl.absoluteString]))
        cell.topView.iconView.addGestureRecognizer(g)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.compose(_:)), for: .touchUpInside)
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.likeButton.setTitle("\(vm.status.like_count)", for: .normal)
        cell.bottomView.likeButton.setImage(.timelineIconUnlike, for: .normal)
        for like in vm.status.like_list {
            if UserAccountViewModel.sharedUserAccount.account?.uid == like["like_uid"] as? String {
                cell.bottomView.likeButton.setImage(.timelineIconLike, for: .normal)
                break
            }
        }
        //cell = self.cell!
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.like(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    @objc func deleteBlog(_ sender: UIButton) {
        NetworkTools.shared.deleteStatus(nil, nil, typeStatus.statusList[sender.tag].status.id) { Result, Error in
            if Error != nil {
                showError("出错了")
                return
            }
            if (Result as! [String:Any])["error"] != nil {
                showError("不能删除别人的博客哦")
                return
            }
            showInfo("删除成功")
            
            NotificationCenter.default.post(name: Notification.Name("BKReloadHomePageDataNotification"), object: self.typeStatus.statusList[sender.tag].status.id)
            self.typeStatus.statusList.remove(at: sender.tag)
            self.tableView.reloadData()
        }
        
    }
    @objc func compose(_ sender: UIButton) {
        let nav = ComposeViewController(nil,typeStatus.statusList[sender.tag].status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func like(_ sender: UIButton) {
        NetworkTools.shared.like(typeStatus.statusList[sender.tag].status.id) { Result, Error in
            if Error == nil {
                Task { @MainActor in
                    self.typeStatus.loadSingleStatus(self.typeStatus.statusList[sender.tag].status.id) { isSuccessful in
                        if(isSuccessful) {
                            self.tableView.reloadData()
                        }
                    }
                }
                if (Result as! [String:Any])["code"] as! String == "add" {
                    showAlert(.timelineIconLike, "你的点赞TA收到了")
                    return
                }
                showAlert(.timelineIconUnlike, "你的取消TA收到了")
                return
            }
            showError("出错了")
            return
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return typeStatus.statusList[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CommentTableViewController(typeStatus.statusList[indexPath.row])
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
}
extension TypeStatusTableViewController: @preconcurrency StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = ACWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
