//
//  LikeStatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

class LikeStatusListViewModel {
    lazy var statusList = [StatusViewModel]()
    var pulldownCount: Int?
    func loadStatus(_ uid: String,finished: @escaping (_ isSuccessed: Bool) -> ()) {
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
            self.cacheSingleImage(dataList: dataList, finished: finished)
        }
    }
    private func cacheSingleImage(dataList: [StatusViewModel],finished: @escaping (_ isSuccessed: Bool) -> ()) {
        let group = DispatchGroup()
        //var dataLength = 0
        for vm in dataList {
            if vm.thumbnailUrls?.count != 1 {
                continue
            }
            let url = vm.thumbnailUrls![0]
            group.enter()
            SDWebImageManager.shared.loadImage(with: url,options: [SDWebImageOptions.retryFailed], progress: nil,completed: { (_,_,_,_,_,_) -> Void in
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            finished(true)
        }
    }
}
