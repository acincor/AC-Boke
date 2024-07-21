//
//  ChatListViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
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
            var arr = [MessageItem]()
            for n in 0..<array.count {
                arr.append(MessageItem(body: array[n]["content"] as! String as NSString, logo: (array[n]["portrait"] as! String), date: NSDate(timeIntervalSince1970:array[n]["timeInterval"] as! TimeInterval), mtype: array[n]["userId"] as? Int == Int(UserAccountViewModel.sharedUserAccount.account!.uid!) ? .Mine : .Someone))
            }
            self.loadChatList(array: arr, finished: finished)
        }
    }
    func loadChatList(array: [MessageItem],finished: @escaping (_ isSuccessed: Bool)->()) {
        self.chatList = array
        finished(true)
    }
}
