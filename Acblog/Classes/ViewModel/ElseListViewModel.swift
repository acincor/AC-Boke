//
//  ElseListViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit


class ElseListViewModel: @unchecked Sendable {
    lazy var list = [UserViewModel]()
    var specialClass: SpecialClass
    init(specialClass: SpecialClass) {
        self.specialClass = specialClass
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
        if specialClass == .friend {
            NetworkTools.shared.loadFriend(finished: completion)
        } else if specialClass == SpecialClass.live{
            NetworkTools.shared.loadLive(finished: completion)
        }
    }
}
