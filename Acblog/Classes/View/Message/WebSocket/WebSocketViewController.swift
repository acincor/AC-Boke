//
//  WebSocketViewController.swift
//  AC博客
//
//  Created by AC on 2023/7/27.
//

import Foundation
import UIKit
import SVProgressHUD
let chatID = "CHATNORMALCELLID"
class WebSocketController: UIViewController,UITableViewDataSource,UITableViewDelegate, @preconcurrency StatusCellDelegate {
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
        cell.bottomView.deleteButton.vm = vm
        cell.bottomView.isHidden = false
        cell.bottomView.deleteButton.addTarget(self, action: #selector(WebSocketController.deleteA(_:)), for: .touchUpInside)
        cell.bottomView.likeButton.addTarget(self, action: #selector(WebSocketController.likeA(_:)), for: .touchUpInside)
        if(vm.status.uid == self.to_uid) {
            vm.status.user = self.username
            cell.bottomView.likeButton.vm = vm
        } else {
            vm.status.user = UserAccountViewModel.sharedUserAccount.account?.user
        }
        if(vm.status.code == "recalled") {
            cell.bottomView.isHidden = true
        } else if(vm.status.code == "like") {
            let attributedString = NSMutableAttributedString(string: vm.status.status ?? "")
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "heart")
            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(attachmentString)
            vm.attributedStatus = attributedString
            cell.bottomView.isHidden = true
        }
        cell.viewModel = vm
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
            guard let imagePath = n.userInfo?["optional"] as? String else {
                return
            }
            guard let image = UIImage(contentsOfFile: imagePath) else {
                return
            }
            guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                return
            }
            
            Task { @MainActor in
                let vc = PhotoBrowserViewController(urls:[],image: image, indexPath: indexPath)
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = self?.photoBrowserAnimator
                self?.photoBrowserAnimator.setDelegateParams(present: cell, using: indexPath, dimissDelegate: vc)
                self?.present(vc, animated: true,completion: nil)
            }
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
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true){ _ in
            Task { @MainActor in
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
            Task { @MainActor in
                SVProgressHUD.dismiss()
                guard error == nil else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("出错了", comment: ""))
                    return
                }
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
                        self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"image\": \"\(i.data()?.base64EncodedString() ?? "")\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\"}")) { error in
                            if let error = error {
                                Task{ @MainActor in
                                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                                }
                            }
                        }
                    }
                }
                self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"status\":\"\(text)\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\"}")) { error in
                    Task { @MainActor in
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
        self.present(UINavigationController(rootViewController: vc), animated: true)
    }
    @objc func likeA(_ sender: UIButton) {
        SVProgressHUD.dismiss()
        Task { @MainActor in
            let text = sender.vm?.status.image != nil ? "[图片]" : (sender.vm?.status.status ?? "")
            self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"status\":\"\(text)\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\",\"code\":\"like\"}")) { error in
            }
        }
    }
    
    func loadData() {
        Task { @MainActor in
            self.statusListViewModel.loadStatus(isPullup:self.refreshView.pullupView.isAnimating,to_uid: self.to_uid) { isSuccessful  in
                Task { @MainActor in
                    self.refreshView.pullupView.stopAnimating()
                    if !isSuccessful {
                        return
                    }
                    self.tableView.reloadData()
                }
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
                    Task { @MainActor in
                        self.isConnect = 1
                    }
                    break
                }
                let data = str.data(using: String.Encoding.utf8)
                var dict = try! JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as! [String : Any]
                Task { @MainActor in
                    print(dict)
                    if(dict["code"] as? String == "delete") {
                        Task { @MainActor in
                            print("did调用")
                            self.refresh(dict["did"] as! Int)
                        }
                    }
                    else if(dict["to_uid"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!) || dict["uid"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!)) {
                        dict["to_uid"] = String(dict["to_uid"] as! Int)
                        StatusDAL.saveChatSingleCache(array: dict)
                        self.loadData()
                    }
                }
            default:
                break
            }
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){ _ in
            Task { @MainActor in
                if self.isConnect == 0 {
                    return
                }
                self.receiveMessage()
            }
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
        loadData()
    }
    @objc func deleteA(_ sender: UIButton) {
        if(sender.vm?.status.uid == self.to_uid) {
            print("delete调用")
            refresh(sender.vm?.status.id ?? 0)
        } else {
            Task { @MainActor in
                self.task.send(.string("{\"did\":\(sender.vm?.status.id ?? 0), \"code\":\"delete\"}")) {error in
                    Task { @MainActor in
                        guard let e = error else{
                            self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"status\":\"撤回了一条消息\",\"to_uid\":\(self.to_uid),\"create_at\":\"\(Date().description(with: Locale(components: .init(identifier: "YYYY/MM/dd HH:mm:ss"))))\",\"code\":\"recalled\"}")) { error in
                                Task { @MainActor in
                                    SVProgressHUD.dismiss()
                                }
                            }
                            return
                        }
                        print(e)
                    }
                }
            }
        }
    }
    @objc func clearData() {
        StatusDAL.clearDataCache(type: .msg)
        self.statusListViewModel.statusList.removeAll()
        loadData()
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
