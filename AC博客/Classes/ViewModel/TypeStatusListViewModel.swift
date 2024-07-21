//
//  TypeStatusListViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit
enum Clas: String {
    case comment = "comment"
    case quote = "quote"
    case like = "like"
    case blog = "blog"
    case friend = "friend"
    case live = "live"
}
class TypeStatusListViewModel {
    lazy var statusList = [StatusViewModel]()
    var pulldownCount: Int?
    var clas: Clas
    init(clas: Clas) {
        self.clas = clas
    }
    func loadStatus(_ uid: String,finished: @escaping (_ isSuccessed: Bool) -> ()) {
        if clas == Clas.blog {
            NetworkTools.shared.profile(uid: uid) { (Result,Error) in
                guard let array = Result as? [[String:Any]] else {
                    finished(false)
                    return
                }
                var dataList = [StatusViewModel]()
                for n in 0..<array.count {
                    dataList.append(StatusViewModel(status: Status(dict: array[n])))
                }
                self.pulldownCount = self.statusList.count == 0 ? dataList.count : (dataList.count > self.statusList.count ? dataList.count - self.statusList.count: nil)
                self.statusList = dataList
                finished(true)
            }
        } else if clas == Clas.like {
            NetworkTools.shared.loadLikeStatus(uid) { Result, Error in
                guard let array = Result as? [[String:Any]] else {
                    finished(false)
                    return
                }
                var dataList = [StatusViewModel]()
                for n in 0..<array.count {
                    dataList.append(StatusViewModel(status: Status(dict: array[n])))
                }
                self.pulldownCount = self.statusList.count == 0 ? dataList.count : (dataList.count > self.statusList.count ? dataList.count - self.statusList.count: nil)
                self.statusList = dataList
                finished(true)
            }
        } else if clas == Clas.comment{
            NetworkTools.shared.loadCommentStatus(uid) { Result, Error in
                guard let array = Result as? [[String:Any]] else {
                    finished(false)
                    return
                }
                var dataList = [StatusViewModel]()
                for n in 0..<array.count {
                    dataList.append(StatusViewModel(status: Status(dict: array[n])))
                }
                self.pulldownCount = self.statusList.count == 0 ? dataList.count : (dataList.count > self.statusList.count ? dataList.count - self.statusList.count: nil)
                self.statusList = dataList
                finished(true)
            }
            
        }
    }
}
