//
//  TypeNeedCacheListViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit
import Kingfisher

class TypeNeedCacheListViewModel: @unchecked Sendable {
    lazy var statusList = [StatusViewModel]()
    var pulldownCount: Int?
    @MainActor func loadSingleStatus(_ id: Int,finished: @escaping @Sendable @MainActor (_ isSuccessful: Bool) -> ()) {
        StatusDAL.loadSingleStatus(id) { array in
            if let array = array {
                for i in 0..<self.statusList.count {
                    if self.statusList[i].status.id == id {
                        self.statusList[i] = StatusViewModel(status: Status(dict: array))
                        finished(true)
                        return
                    }
                }
            }
            finished(false)
        }
    }
    @MainActor func loadStatus(isPullup: Bool? = nil, id: Int? = nil, comment_id: Int? = nil,to_uid: Int? = nil,finished: @escaping @Sendable @MainActor (_ isSuccessful: Bool) -> ()) {
        if let isPullup = isPullup {
            let since_id = isPullup ? 0 : (statusList.first?.status.id ?? 0)
            let max_id = isPullup ? (statusList.last?.status.id ?? 0) : 0
            let completion = { @MainActor @Sendable (array: [[String:Any]]?) in
                guard let array = array else {
                    finished(false)
                    return
                }
                var dataList = [StatusViewModel]()
                for dict in array {
                    dataList.append(StatusViewModel(status: Status(dict: dict)))
                }
                self.pulldownCount = (since_id > 0) ? dataList.count : nil
                if max_id > 0 {
                    self.statusList += dataList
                } else {
                    self.statusList = dataList + self.statusList
                }
                self.cacheSingleImage(dataList: dataList, finished: finished)
            }
            if to_uid == nil {
                StatusDAL.loadStatus(since_id: since_id, max_id: max_id, type: .status, to_uid: nil, finished: completion)
            } else {
                StatusDAL.loadStatus(since_id: since_id, max_id: max_id, type: .msg, to_uid: to_uid, finished: completion)
            }
        } else if let id = id {
            NetworkTools.shared.loadOneStatus(id:id) { Result,Error in
                guard let status = Result as? [String:Any] else {
                    showError("博客加载错误")
                    return
                }
                guard let comment_list = status["comment_list"] as? [[String:Any]] else {
                    showError("评论加载错误")
                    return
                }
                var dataList = [StatusViewModel]()
                if let comment_id = comment_id {
                    for dict in comment_list {
                        if dict["comment_id"] as! String == String(comment_id) {
                            for dictionary in dict["comment_list"] as? [[String:Any]] ?? [] {
                                dataList.append(StatusViewModel(status: Status(dict: dictionary)))
                            }
                            self.statusList = dataList
                            self.cacheSingleImage(dataList: dataList, finished: finished)
                            return
                        }
                    }
                }
                for dict in comment_list {
                    dataList.append(StatusViewModel(status: Status(dict: dict)))
                }
                self.statusList = dataList
                self.cacheSingleImage(dataList: dataList, finished: finished)
            }
        }
    }
    @MainActor private func cacheSingleImage(dataList: [StatusViewModel],finished: @escaping @Sendable @MainActor (_ isSuccessful: Bool) -> ()) {
        let group = DispatchGroup()
        //var dataLength = 0
        for vm in dataList {
            if vm.thumbnailUrls?.count != 1 && vm.status.image == nil {
                continue
            }
            group.enter()
            if let i = vm.status.image {
                if let d = Data(base64Encoded: i) {
                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
                    path = (path as NSString).appendingPathComponent(String(vm.status.id)+"."+d.detectImageType().1.rawValue)
                    vm.status.image = path
                    do {
                        try d.write(to: URL(fileURLWithPath: path))
                    } catch {
                        showError("缓存第"+String(vm.status.id)+"图片失败")
                    }
                    
                }
            } else {
                let url = vm.thumbnailUrls![0]
                ImageDownloader.default.downloadImage(with: url, options:[.retryStrategy(DelayRetryStrategy(maxRetryCount: 12, retryInterval: .seconds(1))),.fromMemoryCacheOrRefresh],progressBlock: nil) {
                    result in
                    guard (try? result.get()) != nil else {
                        return
                    }
                     //dataLength = dataLength + data.count
                }
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            finished(true)
        }
    }
}
