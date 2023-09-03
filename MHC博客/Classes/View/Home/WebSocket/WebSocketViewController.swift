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
    
    func chatTableView(tableView: TableView, dataForRow: Int) -> MessageItem {
        return self.chatListViewModel.chatList[dataForRow]
    }
    /// tcp握手
    var chatListViewModel = ChatListViewModel()
    //对方和自己将会是两个连接，这个urlRequestToUid是对方的，因为我们在实例化后才会传参，所以要先设URLRequest的url为空(NSURL() as URL())，我们要接收两者的
    var urlRequestToUid = URLRequest(url: NSURL() as URL) // variable
        //let urlRequest = URLRequest(url: URL(string:"http://localhost:8080/\(UserAccountViewModel.sharedUserAccount.account!.uid!)/\(UserAccountViewModel.sharedUserAccount.account!.uid!)")!)//本地测试
    let urlRequest = URLRequest(url: URL(string:"wss://wss.lmyz6.cn/\(UserAccountViewModel.sharedUserAccount.account!.uid!)/\(UserAccountViewModel.sharedUserAccount.account!.uid!)")!)
    lazy var urlSession = URLSession(configuration: .default)
    lazy var task = urlSession.webSocketTask(with: urlRequest)
    lazy var urlRequestToUidTask = urlSession.webSocketTask(with: urlRequestToUid)
    var to_uid: Int?
    var username: String?
    lazy var textField = UITextField()
    lazy var sendButton = UIButton()
    lazy var table:TableView = TableView(frame: CGRectZero, style: .plain)
    lazy var viewTitle = UILabel(title: username!)
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
        table.chatDataSource = self
                textField.snp.makeConstraints { make in
                    make.left.equalTo(20)
                    make.bottom.equalTo(view.snp.bottom).offset(-10)
                }
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
                textField.placeholder = "说些话吧，哪怕是一个标点符号也行..."
                sendButton.setTitle("发送", for: .normal)
                sendButton.setTitleColor(.white, for: .normal)
                sendButton.backgroundColor = .red
                textField.sizeToFit()
                sendButton.sizeToFit()
        urlRequestToUidTask.receive {[weak self]result in
            switch result {
            case .failure(_):
                break
            case .success(.string(let str)):
                let data = str.data(using: String.Encoding.utf8)
                            let dict = try! JSONSerialization.jsonObject(with: data!,
                                                                            options: .mutableContainers) as! [String : Any]
                if(dict["isHESHE"] as! Int == 0) {
                                    SVProgressHUD.showInfo(withStatus: "对方未在线")
                                    DispatchQueue.main.async {
                                        self?.sendButton.tag = 0
                                    }
                                } else {
                                    SVProgressHUD.showInfo(withStatus: "对方在线了 sb is on line.")
                                    DispatchQueue.main.async {
                                        self?.sendButton.tag = 1
                                    }
                                }
            default:
                break
            }
        }
        let leftbar = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.close))
        leftbar.tintColor = .red
        leftbar.title = "关闭"
        navigationItem.leftBarButtonItem = leftbar
        let rightbar = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.clearData))
        rightbar.tintColor = .red
        rightbar.title = "删除聊天记录"
        navigationItem.rightBarButtonItem = rightbar
        sendButton.addTarget(self, action: #selector(self.send(_:)), for: .touchUpInside)
        receiveMessage()
    }
    func connect() {
        SVProgressHUD.show()
            task.resume()
        guard let uid = to_uid else {
            SVProgressHUD.dismiss()
            return
        }
        //urlRequestToUid = URLRequest(url: URL(string:"http://localhost:8080/\(uid)/\(UserAccountViewModel.sharedUserAccount.account!.uid!)")!)//本地测试
        urlRequestToUid = URLRequest(url: URL(string:"wss://wss.lmyz6.cn/\(uid)/\(UserAccountViewModel.sharedUserAccount.account!.uid!)")!)
        urlRequestToUidTask = urlSession.webSocketTask(with: urlRequestToUid)
        urlRequestToUidTask.sendPing { error in
            SVProgressHUD.dismiss()
            guard error == nil else {
                SVProgressHUD.showInfo(withStatus: "出错了")
                return
            }
        }
        urlRequestToUidTask.resume()
    }
    @objc func send(_ sender: UIButton) {
        if textField.hasText && sender.tag == 1 {
            let text = self.textField.text!//UITextField.text must be used from main thread only
            SVProgressHUD.show()
            sendButton.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self.task.send(.string("{\"uid\":\(UserAccountViewModel.sharedUserAccount.account!.uid!),\"content\":\"\(self.textField.text!)\",\"to_uid\":\(self.to_uid!),\"timeInterval\":\(Date().timeIntervalSince1970)}")) { error in
                    guard error != nil else {
                        SVProgressHUD.dismiss()
                        ChatDAL.saveCache(array: ["uid":Int(UserAccountViewModel.sharedUserAccount.account!.uid!)!,"content":text,"to_uid":self.to_uid!,"timeInterval":Date().timeIntervalSince1970])
                        return
                    }
                    SVProgressHUD.dismiss()
                    self.sendButton.isEnabled = true
                }
            }
        } else {
            SVProgressHUD.showInfo(withStatus: "对方未在线或您没有发送文字 sb isn't on line or you send blank text.")
        }
    }
    
    func stop() {
        task.cancel(with: .goingAway, reason: nil)
    }
    var messageList = [[String:Any]]()
    private func receiveMessage(){
        self.chatListViewModel.loadStatus(to_uid: self.to_uid!) { isSuccessed in
            if isSuccessed {
                return
            }
            SVProgressHUD.showInfo(withStatus: "出错了")
        }
        table.reloadData()
        //table.removeFromSuperview()
        //self.view.addSubview(table)
        self.chatListViewModel.chatList.removeAll()
        urlRequestToUidTask.receive {[weak self]result in
            switch result {
            case .failure(_):
                break
            case .success(.string(let str)):
                let data = str.data(using: String.Encoding.utf8)
                let dict = try! JSONSerialization.jsonObject(with: data!,
                                                             options: .mutableContainers) as! [String : Any]
                if(dict["isHESHE"] as! Int == 1) {
                    SVProgressHUD.showInfo(withStatus: "对方在线了 sb is on line.")
                    DispatchQueue.main.async {
                        self?.sendButton.tag = 1
                    }
                } else {
                    SVProgressHUD.showInfo(withStatus: "对方未在线 sb isn't on line.")
                    DispatchQueue.main.async {
                        self?.sendButton.tag = 0
                    }
                }
                if(dict["to_uid"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!)) {
                    ChatDAL.saveCache(array: ["uid":dict["uid"] as! Int,"content":dict["content"] as! String,"to_uid":Int(UserAccountViewModel.sharedUserAccount.account!.uid!)!,"timeInterval":dict["timeInterval"] as! TimeInterval])
                }
            default:
                break
            }
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){ _ in
            self.task.sendPing { error in
                guard error != nil else {
                    return
                }
            }
            self.urlRequestToUidTask.sendPing { error in
                guard error != nil else {
                    return
                }
            }
            self.receiveMessage()
            
        }
    }
    @objc func close() {
        self.dismiss(animated: false)
    }
    @objc func clearData() {
        ChatDAL.clearDataCache()
    }
}
