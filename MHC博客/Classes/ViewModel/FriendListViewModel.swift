//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


class FriendListViewModel {
    lazy var friendList = [FriendViewModel]()
    func loadFriend(finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.shared.loadFriend { (array,error) -> () in
            guard let array = array else {
                //print("数据格式错误")
                //print("array转换错误")
                finished(false)
                return
            }
            guard let arr = array as? [[String:Any]] else {
                return
            }
            var dataList = [FriendViewModel]()
                for n in 0..<arr.count {
                    //print(FriendAccount(dict: dict))
                    dataList.append(FriendViewModel(friend: FriendAccount(dict: arr[n])))
                }
            self.friendList = dataList
                //print(dataList)
                //print("bool:",dataList.count > self.friendList.count)
                //print(self.friendList)
                finished(true)
        }
    }
}
