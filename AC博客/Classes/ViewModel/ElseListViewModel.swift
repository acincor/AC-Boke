//
//  ElseListViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit


class ElseListViewModel {
    lazy var list = [UserViewModel]()
    var clas: Clas
    init(clas: Clas) {
        self.clas = clas
    }
    func load(finished: @escaping (_ isSuccessed: Bool) -> ()) {
        if clas == .friend {
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
                self.list = dataList
                finished(true)
            }
        } else if clas == Clas.live{
            NetworkTools.shared.loadLive { (array,error) -> () in
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
        }
    }
}
