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
class TypeStatusListViewModel: @unchecked Sendable {
    lazy var statusList = [StatusViewModel]()
    var pulldownCount: Int?
    var clas: Clas
    init(clas: Clas) {
        self.clas = clas
    }
    @MainActor func loadSingleStatus(_ id: Int,finished: @escaping @Sendable @MainActor (_ isSuccessful: Bool) -> ()) {
        StatusDAL.loadSingleStatus(id) { array in
            if let array = array {
                for i in 0..<self.statusList.count {
                    if self.statusList[i].status.id == id {
                        self.statusList[i].status = Status(dict: array)
                        finished(true)
                        return
                    }
                }
            }
            finished(false)
        }
    }
    @MainActor func loadStatus(_ uid: String,finished: @escaping @Sendable (_ isSuccessful: Bool) -> ()) {
        let completion: NetworkTools.HMRequestCallBack = {(Result: Any, error: Error?) in
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
        if clas == Clas.blog {
            NetworkTools.shared.profile(uid: uid, finished: completion)
        } else if clas == Clas.like {
            NetworkTools.shared.loadLikeStatus(uid, finished: completion)
        } else if clas == Clas.comment{
            NetworkTools.shared.loadCommentStatus(uid, finished: completion)
        }
    }
}
