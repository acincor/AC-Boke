//
//  WebSocketViewController.swift
//  MHC博客
//
//  Created by mhc team on 2023/7/27.
//

import Foundation
import UIKit
class WebSocketController: UIViewController,ChatDataSource {
    func rowsForChatTable(tableView: TableView) -> Int {
        return chatListViewModel.chatList.count
    }
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    func chatTableView(tableView: TableView, dataForRow: Int) -> MessageItem {
        return self.chatListViewModel.chatList[dataForRow]
    }
    /// tcp握手
    init(to_uid: Int, username: String) {
        self.to_uid = to_uid
        self.username = username
        self.urlRequest = URLRequest(url: URL(string:"ws://localhost:8081/\(UserAccountViewModel.sharedUserAccount.account!.uid!)/\(to_uid)")!)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var chatListViewModel = ChatListViewModel()
    //let urlRequest = URLRequest(url: URL(string:"http://localhost:8080/\(UserAccountViewModel.sharedUserAccount.account!.uid!)/\(UserAccountViewModel.sharedUserAccount.account!.uid!)")!)//本地测试
    lazy var urlSession = URLSession(configuration: .default)
    var urlRequest: URLRequest
    lazy var task = urlSession.webSocketTask(with: urlRequest)
    var to_uid: Int
    var username: String
    lazy var textField = UITextField()
    lazy var sendButton = UIButton()
    lazy var table:TableView = TableView(frame: CGRectZero, style: .plain)
    lazy var viewTitle = UILabel(title: username)
    override func viewDidLoad() {
        connect()
        SVProgressHUD.dismiss()
        view.backgroundColor = .systemBackground
                view.addSubview(textField)
                view.addSubview(sendButton)
                view.addSubview(table)
        view.addSubview(viewTitle)
        table.register(TableViewCell.self, forCellReuseIdentifier: "MsgCell")
                //数据协议
                    //代理方法
        textField.snp.makeConstraints { make in
            make.bottom.equalTo(textField.frame.height)
            make.width.equalTo((UIScreen.main.bounds.width - self.sendButton.frame.width) / 2)
            make.centerX.equalTo(self.table.snp.centerX)
        }
        table.chatDataSource = self
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(textField.snp.right)
            make.bottom.equalTo(textField.snp.bottom)
        }
        table.snp.makeConstraints { make in
            make.bottom.equalTo(sendButton.snp.top).offset(-20)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(view.snp.top).offset(20)
        }
        
        table.tableHeaderView = viewTitle
        /*
        viewTitle.snp.makeConstraints { make in
            make.bottom.equalTo(table.snp.top)
            make.left.equalTo(table.snp.left)
        }
         */
                sendButton.layer.cornerRadius = 15
                sendButton.layer.masksToBounds = true
                textField.placeholder = NSLocalizedString("说些话吧，哪怕是一个标点符号也行...", comment: "")
        
                sendButton.setTitle(NSLocalizedString("发送", comment: ""), for: .normal)
                sendButton.setTitleColor(.white, for: .normal)
                sendButton.backgroundColor = .red
        textField.textAlignment = .natural
        textField.adjustsFontSizeToFitWidth = true
                textField.sizeToFit()
                sendButton.sizeToFit()
        let leftbar = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.close))
        leftbar.tintColor = .red
        leftbar.title = NSLocalizedString("关闭", comment: "")
        navigationItem.leftBarButtonItem = leftbar
        let rightbar = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.clearData))
        rightbar.tintColor = .red
        rightbar.title = NSLocalizedString("删除聊天记录", comment: "")
        navigationItem.rightBarButtonItem = rightbar
        sendButton.addTarget(self, action: #selector(self.send(_:)), for: .touchUpInside)
        receiveMessage()
    }
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
    @objc func send(_ sender: UIButton) {
        if textField.hasText {
            let text = self.textField.text!//UITextField.text must be used from main thread only
            SVProgressHUD.show()
            sendButton.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"portrait\":\"\(UserAccountViewModel.sharedUserAccount.account!.portrait!)\",\"content\":\"\(self.textField.text!)\",\"to_uid\":\(self.to_uid),\"timeInterval\":\(Date().timeIntervalSince1970)}")) { error in
                    guard error != nil else {
                        SVProgressHUD.dismiss()
                        ChatDAL.saveCache(array: ["uid":Int(UserAccountViewModel.sharedUserAccount.account!.uid!)!,"portrait":UserAccountViewModel.sharedUserAccount.account!.portrait!,"content":text,"to_uid":self.to_uid,"timeInterval":Date().timeIntervalSince1970])
                        DispatchQueue.main.async {
                            self.sendButton.isEnabled = true
                        }
                        return
                    }
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func stop() {
        task.cancel(with: .goingAway, reason: nil)
    }
    var messageList = [[String:Any]]()
    private func receiveMessage(){
        self.chatListViewModel.loadStatus(to_uid: self.to_uid) { isSuccessed in
            print(isSuccessed)
            if !isSuccessed {
                return
            }
        }
        table.reloadData()
        task.receive {result in
            switch result {
            case .failure(_):
                break
            case .success(.string(let str)):
                let data = str.data(using: String.Encoding.utf8)
                let dict = try! JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as! [String : Any]
                if(dict["to_uid"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!)) {
                    ChatDAL.saveCache(array: ["uid":dict["uid"] as! Int,"portrait":dict["portrait"] as! String,"content":dict["content"] as! String,"to_uid":Int(UserAccountViewModel.sharedUserAccount.account!.uid!)!,"timeInterval":dict["timeInterval"] as! TimeInterval])
                }
            default:
                break
            }
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){ _ in
            if self.isConnect == 0 {
                return
            }
            self.task.sendPing { error in
                guard error != nil else {
                    return
                }
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
    @objc func clearData() {
        ChatDAL.clearDataCache()
    }
}
