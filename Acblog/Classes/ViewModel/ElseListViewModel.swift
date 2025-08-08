//
//  ElseListViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit


class ElseListViewModel: @unchecked Sendable {
    lazy var list = [UserViewModel]()
    var clas: Clas
    init(clas: Clas) {
        self.clas = clas
    }
    @MainActor func load(finished: @escaping @Sendable (_ isSuccessful: Bool) -> ()) {
        let completion: NetworkTools.HMRequestCallBack = { (array: Any?,error: Error?) -> () in
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
            
            self.list = dataList
            finished(true)
        }
        if clas == .friend {
            NetworkTools.shared.loadFriend(finished: completion)
        } else if clas == Clas.live{
            NetworkTools.shared.loadLive(finished: completion)
        }
    }
}
