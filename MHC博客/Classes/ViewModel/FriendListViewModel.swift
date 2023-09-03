//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


class FriendListViewModel {
    lazy var friendList = [UserViewModel]()
    func loadFriend(finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.shared.loadFriend { (array,error) -> () in
            guard let array = array else {
                finished(false)
                return
            }
            guard let arr = array as? [[String:Any]] else {
                return
            }
            var dataList = [UserViewModel]()
                for n in 0..<arr.count {
                    dataList.append(UserViewModel(user: Account(dict: arr[n])))
                }
            self.friendList = dataList
                finished(true)
        }
    }
}
