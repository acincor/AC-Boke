//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

class ChatListViewModel {
    lazy var chatList = [MessageItem]()
    func loadStatus(to_uid: Int,finished: @escaping (_ isSuccessed: Bool) -> ()) {
        ChatDAL.ChatStatus(to_uid: to_uid) { (array) -> () in
            guard let array = array else {
                //print("数据格式错误")
                finished(false)
                return
            }
            //print(result)
            for n in 0..<array.count {
                //print(array[n])
                //print(Status(dict: array[n]))
                NetworkTools.shared.loadUserInfo(uid: array[n]["userId"] as! Int) { Result, Error in
                    guard let Result else{
                        //print(Error)
                        return
                    }
                    self.chatList.append(MessageItem(body: array[n]["content"] as! String as NSString, logo: (Result as! [String:Any])["portrait"]as! String, date: NSDate(timeIntervalSince1970:array[n]["timeInterval"] as! TimeInterval), mtype: array[n]["userId"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!) ? .Mine : .Someone))
                }
                self.loadChatList(array: self.chatList, finished: finished)
            }
            //print("bool:",dataList.count > self.statusList.count)
        }
    }
    func loadChatList(array: [MessageItem],finished: @escaping (_ isSuccessed: Bool)->()) {
        self.chatList = array
        finished(true)
    }
}
