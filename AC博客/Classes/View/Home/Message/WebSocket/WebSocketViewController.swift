//
//  WebSocketViewController.swift
//  AC博客
//
//  Created by AC on 2023/7/27.
//

import Foundation
import UIKit
let chatID = "CHATNORMALCELLID"
class WebSocketController: UIViewController,UITableViewDataSource,UITableViewDelegate, StatusCellDelegate {
    func statusCellDidClickUrl(url: URL) {
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func present(_ controller: UIViewController) {
        self.present(controller,animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusListViewModel.statusList.count
    }
    
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    /// tcp握手
    init(to_uid: Int, username: String) {
        self.to_uid = to_uid
        self.username = username
        self.urlRequest = URLRequest(url: URL(string:"wss://wss.mhcincapi.top/\(UserAccountViewModel.sharedUserAccount.account!.uid!)/\(to_uid)")!)
        super.init(nibName: nil, bundle: nil)
        tableView.register(StatusNormalCell.self, forCellReuseIdentifier: chatID)
    }
    let tableView = UITableView()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = statusListViewModel.statusList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: chatID, for: indexPath) as! StatusCell
        cell.bottomView.deleteButton.tag = vm.status.id
        cell.bottomView.isHidden = false
        if(vm.status.uid == self.to_uid) {
            vm.status.user = self.username
            cell.bottomView.likeButton.vm = vm
            cell.bottomView.deleteButton.setTitle(NSLocalizedString("删除", comment: ""), for: .normal)
            cell.bottomView.likeButton.setTitle(NSLocalizedString("赞", comment: ""), for: .normal)
            cell.bottomView.likeButton.isHidden = false
            cell.bottomView.deleteButton.addTarget(self, action: #selector(self.deleteA(_:)), for: .touchUpInside)
            cell.bottomView.likeButton.addTarget(self, action: #selector(self.likeA(_:)), for: .touchUpInside)
            cell.bottomView.deleteButton.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(cell.bottomView.snp.top)
                make.left.equalTo(cell.bottomView.snp.left)
                make.bottom.equalTo(cell.bottomView.snp.bottom)
            }
            cell.bottomView.likeButton.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(cell.bottomView.deleteButton.snp.top)
                make.left.equalTo(cell.bottomView.deleteButton.snp.right)
                make.width.equalTo(cell.bottomView.deleteButton.snp.width)
                make.height.equalTo(cell.bottomView.deleteButton.snp.height)
                make.right.equalTo(cell.bottomView.snp.right)
            }
        } else {
            vm.status.user = UserAccountViewModel.sharedUserAccount.account?.user
            cell.bottomView.deleteButton.setTitle(NSLocalizedString("撤回", comment: ""), for: .normal)
            cell.bottomView.deleteButton.addTarget(self, action: #selector(self.recallA(_:)), for: .touchUpInside)
            cell.bottomView.likeButton.isHidden = true
            cell.bottomView.deleteButton.snp.remakeConstraints { (make) -> Void in
                make.left.equalTo(cell.bottomView.snp.left)
                make.top.equalTo(cell.bottomView.snp.top)
                make.right.equalTo(cell.bottomView.snp.right)
                make.bottom.equalTo(cell.bottomView.snp.bottom)
            }
        }
        if(vm.status.code == "recalled") {
            cell.bottomView.isHidden = true
        } else if(vm.status.code == "like") {
            let attributedString = NSMutableAttributedString(string: vm.status.status)
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "heart")
            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(attachmentString)
            vm.attributedStatus = attributedString
            cell.bottomView.isHidden = true
        }
        cell.viewModel = vm
        cell.bottomView.commentButton.removeFromSuperview()
        cell.cellDelegate = self
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    var statusListViewModel = TypeNeedCacheListViewModel()
    //let urlRequest = URLRequest(url: URL(string:"http://localhost:8080/\(UserAccountViewModel.sharedUserAccount.account!.uid!)/\(UserAccountViewModel.sharedUserAccount.account!.uid!)")!)//本地测试
    lazy var urlSession = URLSession(configuration: .default)
    var urlRequest: URLRequest
    lazy var task = urlSession.webSocketTask(with: urlRequest)
    var to_uid: Int
    var username: String
    lazy var sendButton = UIButton()
    lazy var viewTitle = UILabel(title: username)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        connect()
        tableView.tableFooterView = refreshView
        refreshView.refreshAction = {pullupView in
            if(pullupView.isAnimating) {
                self.loadData()
            }
        }
        NotificationCenter.default.addObserver(forName: Notification.Name(WBStatusSelectedPhotoNotification), object: nil, queue: nil) {[weak self] n in
            guard let indexPath = n.userInfo?[WBStatusSelectedPhotoIndexPathKey] as? IndexPath else {
                return
            }
            guard let imagePath = n.userInfo?[WBStatusSelectedPhotoURLsKey] as? String else {
                return
            }
            guard let image = UIImage(contentsOfFile: imagePath) else {
                return
            }
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            let vc = PhotoBrowserViewController(urls:[],image: image, indexPath: indexPath)
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self?.photoBrowserAnimator
            self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
            self?.present(vc, animated: true,completion: nil)
        }
        SVProgressHUD.dismiss()
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(sendButton)
        //数据协议
        tableView.dataSource = self
        //代理方法
        tableView.delegate = self
        sendButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.centerX.equalTo(view.snp.centerX)
            make.height.equalTo(44)
            make.width.equalTo(view.snp.width)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(sendButton.snp.top)
        }
        tableView.tableHeaderView = viewTitle
        /*
         viewTitle.snp.makeConstraints { make in
         make.bottom.equalTo(table.snp.top)
         make.left.equalTo(table.snp.left)
         }
         */
        sendButton.setTitle(NSLocalizedString("发送", comment: ""), for: .normal)
        sendButton.setTitleColor(.orange, for: .normal)
        sendButton.backgroundColor = .red
        let leftbar = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.close))
        leftbar.tintColor = .red
        leftbar.title = NSLocalizedString("关闭", comment: "")
        navigationItem.leftBarButtonItem = leftbar
        let rightbar = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.clearData))
        rightbar.tintColor = .red
        rightbar.title = NSLocalizedString("删除聊天记录", comment: "")
        navigationItem.rightBarButtonItem = rightbar
        sendButton.addTarget(self, action: #selector(self.send(_:)), for: .touchUpInside)
        task.maximumMessageSize = 52428800
        self.loadData()
        DispatchQueue.global(qos: .background).async {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true){ _ in
                self.task.sendPing { error in
                    if(error != nil) {
                        return
                    }
                }
            }
        }
        receiveMessage()
    }
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
    func connect() {
        SVProgressHUD.show()
        task.resume()
        isConnect = 1
        //urlRequestToUid = URLRequest(url: URL(string:"http://localhost:8080/\(uid)/\(UserAccountViewModel.sharedUserAccount.account!.uid!)")!)//本地测试
        task.sendPing { error in
            SVProgressHUD.dismiss()
            guard error == nil else {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                return
            }
        }
    }
    lazy var refreshView = CustomRefreshView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
    @objc func send(_ sender: UIButton) {
        let vc = ComposeViewController(nil, nil,true)
        vc.finished = { text, image in
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                SVProgressHUD.show()
                for i in image {
                    // 将JSON数据转换为String以便打印或查看
                    DispatchQueue.main.asyncAfter(deadline: .now()+1){
                        self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"image\": \"\(i.sd_imageData()?.base64EncodedString() ?? "")\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\"}")) { error in
                            //print(error)
                        }
                    }
                }
                self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"status\":\"\(text)\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\"}")) { error in
                    SVProgressHUD.dismiss()
                }
            }
        }
        self.present(UINavigationController(rootViewController: vc), animated: true)
    }
    @objc func recallA(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.task.send(.string("{\"did\":\(sender.tag), \"code\":\"delete\"}")) {error in
                guard let e = error else{
                    self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"status\":\"撤回了一条消息\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\",\"code\":\"recalled\"}")) { error in
                        SVProgressHUD.dismiss()
                    }
                    return
                }
                print(e)
            }
        }
    }
    @objc func likeA(_ sender: UIButton) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            let text = sender.vm?.status.image != nil ? "[图片]" : (sender.vm?.status.status ?? "")
            self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"status\":\"\(text)\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\",\"code\":\"like\"}")) { error in
            }
        }
    }
    @objc func deleteA(_ sender: UIButton) {
        refresh(sender.tag)
    }
    func loadData() {
        DispatchQueue.main.async {
            self.statusListViewModel.loadStatus(isPullup:self.refreshView.pullupView.isAnimating,to_uid: self.to_uid) { isSuccessed  in
                self.refreshView.pullupView.stopAnimating()
                if !isSuccessed {
                    return
                }
                self.tableView.reloadData()
            }
        }
    }
    private func receiveMessage(){
        task.receive {result in
            switch result {
            case .failure(let e):
                print(e)
                break
            case .success(.string(let str)):
                if(str == "Pong") {
                    self.isConnect = 1
                    break
                }
                let data = str.data(using: String.Encoding.utf8)
                var dict = try! JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as! [String : Any]
                if(dict["code"] as? String == "delete") {
                    DispatchQueue.main.async {
                        self.refresh(dict["did"] as! Int)
                    }
                }
                else if(dict["to_uid"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!) || dict["uid"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!)) {
                    dict["to_uid"] = String(dict["to_uid"] as! Int)
                    StatusDAL.saveChatSingleCache(array: dict)
                    self.loadData()
                }
            default:
                break
            }
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){ _ in
            if self.isConnect == 0 {
                return
            }
            self.receiveMessage()
        }
    }
    var isConnect = 0
    @objc func close() {
        self.task.cancel()
        isConnect = 0
        self.dismiss(animated: true)
    }
    func refresh(_ id: Int) {
        StatusDAL.removeCache(id, .msg)
        if let i = self.statusListViewModel.statusList.firstIndex(where: {
            vm in
            vm.status.id == id
        }) {
            self.statusListViewModel.statusList.remove(at: i)
        }
        self.tableView.reloadData()
    }
    @objc func clearData() {
        StatusDAL.clearDataCache(type: .msg)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.statusListViewModel.statusList[indexPath.row].rowHeight
    }
}
/*extension StatusViewModel {
 static func == (lhs: StatusViewModel, rhs: StatusViewModel) -> Bool {
 if lhs.status == rhs.status && lhs.thumbnailUrls == rhs.thumbnailUrls && rhs.attributedStatus == lhs.attributedStatus && rhs.cellId == lhs.cellId {
 return true
 } else {
 return false
 }
 }
 }
 extension Array<StatusViewModel> {
 static func == (lhs: [StatusViewModel], rhs: [StatusViewModel]) -> Bool {
 if(lhs.count != rhs.count) {
 return false
 }
 if(lhs.count == rhs.count) {
 var c = 0
 for i in 0..<rhs.count {
 if(lhs[i] == rhs[i]) {
 c += 1
 }
 }
 if(c == lhs.count) {
 return true
 }
 }
 return false
 }
 }
 */
