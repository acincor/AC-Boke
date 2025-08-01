//
//  TypeStatusTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit
import SwiftUI
import SVProgressHUD


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
        refreshControl = WBRefreshControl()
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
        guard let url = ("https://mhcincapi.top/hls/\(vm.user.uid).m3u8").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("似乎出了点问题，请刷新重试", comment: ""))
            return
        }
        guard let urlEncoded = URL(string:url) else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("似乎出了点问题，请刷新重试", comment: ""))
            return
        }
        present(HomeWebViewController(url: urlEncoded),animated: true)
    }
    @objc func loadData() {
        self.refreshControl?.beginRefreshing()
        //StatusDAL.clearDataCache()//删除缓存
        typeStatus.loadStatus(uid) { isSuccessed in
            Task { @MainActor in
                self.refreshControl?.endRefreshing()
                if !isSuccessed {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("加载数据错误，请稍后重试", comment: ""))
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
        self.loadData()
    }
    @objc func action(sender: UITapGestureRecognizer) {
        let dict = ["portrait": sender.sender3, "user": sender.sender2, "uid": sender.sender]
        let uvm = UserViewModel(user: Account(dict: dict as [String : Any]))
        present(UINavigationController(rootViewController: UIHostingController(rootView: UserNavigationLinkView(account: uvm, uid: sender.sender ?? ""))), animated: true)
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
        cell.bottomView.deleteButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        let g = UITapGestureRecognizer(target: self, action: #selector(self.action(sender:)))
        guard let viewModel = cell.topView.viewModel else {
            return cell
        }
        g.sender = "\(viewModel.status.uid)"
        g.sender2 = "\(viewModel.status.user ?? "")"
        g.sender3 = "\(viewModel.status.portrait ?? "")"
        cell.topView.iconView.addGestureRecognizer(g)
        cell.bottomView.commentButton.tag = indexPath.row
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        let result = ["id":"\(typeStatus.statusList[indexPath.row].status.id)","like_uid":UserAccountViewModel.sharedUserAccount.account!.uid!] as [String:Any]
        cell.bottomView.likeButton.setTitle("\(typeStatus.statusList[indexPath.row].status.like_count)", for: .normal)
        let uid = result["like_uid"] as? String
        NetworkTools.shared.loadOneStatus(id: typeStatus.statusList[indexPath.row].status.id) { res, error in
            if error != nil {
                return
            }
            guard let list = res as? [String:Any] else {
                return
            }
            Task { @MainActor in
                cell.bottomView.commentButton.setTitle(list["comment_count"] as? String, for: .normal)
                cell.bottomView.likeButton.setTitle(list["like_count"] as? String, for: .normal)
                guard let like_list = list["like_list"] as? [[String:Any]] else {
                    return
                }
                
                for s in like_list {
                    if uid == s["like_uid"] as? String {
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
        }
        //cell = self.cell!
        cell.bottomView.likeButton.tag = indexPath.row
        cell.bottomView.likeButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        cell.cellDelegate = self
        return cell
    }
    @objc func action1(_ sender: UIButton) {
        NetworkTools.shared.deleteStatus(nil, nil, typeStatus.statusList[sender.tag].status.id) { Result, Error in
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
                StatusDAL.removeCache(self.typeStatus.statusList[sender.tag].status.id, .status)
                if let i = listViewModel.statusList.firstIndex(where: { vm in
                    vm.status.id == self.typeStatus.statusList[sender.tag].status.id
                }) {
                    listViewModel.statusList.remove(at: i)
                }
                NotificationCenter.default.post(name: Notification.Name("BKReloadHomePageDataNotification"), object: nil)
                self.typeStatus.statusList.remove(at: sender.tag)
                self.tableView.reloadData()
            }
        }
        
    }
    @objc func action3(_ sender: UIButton) {
        let nav = ComposeViewController(nil,typeStatus.statusList[sender.tag].status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
    @objc func action4(_ sender: UIButton) {
        NetworkTools.shared.like(typeStatus.statusList[sender.tag].status.id) { Result, Error in
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
                    self.tableView.reloadData()
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return typeStatus.statusList[indexPath.row].rowHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CommentTableViewController(viewModel: typeStatus.statusList[indexPath.row])
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        self.present(nav, animated: false)
    }
}
extension TypeStatusTableViewController: @preconcurrency StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
}
