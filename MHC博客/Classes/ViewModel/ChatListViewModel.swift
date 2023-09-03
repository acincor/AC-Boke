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
                finished(false)
                return
            }
            for n in 0..<array.count {
                NetworkTools.shared.loadUserInfo(uid: array[n]["userId"] as! Int) { Result, Error in
                    guard let Result else{
                        return
                    }
                    self.chatList.append(MessageItem(body: array[n]["content"] as! String as NSString, logo: (Result as! [String:Any])["portrait"]as! String, date: NSDate(timeIntervalSince1970:array[n]["timeInterval"] as! TimeInterval), mtype: array[n]["userId"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!) ? .Mine : .Someone))
                }
                self.loadChatList(array: self.chatList, finished: finished)
            }
        }
    }
    func loadChatList(array: [MessageItem],finished: @escaping (_ isSuccessed: Bool)->()) {
        self.chatList = array
        finished(true)
    }
}
