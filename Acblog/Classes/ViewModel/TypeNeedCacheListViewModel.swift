//
//  TypeNeedCacheListViewModel.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit
import SVProgressHUD
import SDWebImage

class TypeNeedCacheListViewModel: @unchecked Sendable {
    lazy var statusList = [StatusViewModel]()
    var pulldownCount: Int?
    @MainActor func loadStatus(isPullup: Bool? = nil, id: Int? = nil, comment_id: Int? = nil,to_uid: Int? = nil,finished: @escaping @Sendable @MainActor (_ isSuccessed: Bool) -> ()) {
        if let isPullup = isPullup {
            let since_id = isPullup ? 0 : (statusList.first?.status.id ?? 0)
            let max_id = isPullup ? (statusList.last?.status.id ?? 0) : 0
            if to_uid == nil {
                StatusDAL.loadStatus(since_id: since_id, max_id: max_id, type: .status, to_uid: nil) { (array) -> () in
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
            } else {
                StatusDAL.loadStatus(since_id: since_id, max_id: max_id, type: .msg, to_uid: to_uid) { (array) -> () in
                    guard let array = array else {
                        finished(false)
                        return
                    }
                    var dataList = [StatusViewModel]()
                    for dict in array {
                        dataList.append(StatusViewModel(status: Status(dict: dict)))
                    }
                    if max_id > 0 {
                        self.statusList += dataList
                    } else {
                        self.statusList = dataList + self.statusList
                    }
                    self.cacheSingleImage(dataList: dataList, finished: finished)
                }
            }
        } else if let id = id {
            if let comment_id = comment_id {
                NetworkTools.shared.loadOneStatus(id:id) { Result,Error in
                    guard let status = Result as? [String:Any] else {
                        Task { @MainActor in
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("博客加载错误", comment: ""))
                        }
                        return
                    }
                    guard let comment_list = status["comment_list"] as? [[String:Any]] else {
                        Task { @MainActor in
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("评论加载错误", comment: ""))
                        }
                        return
                    }
                    var dataList = [StatusViewModel]()
                    for dict in comment_list {
                        if dict["comment_id"] as! String == String(comment_id) {
                            for dictionary in dict["comment_list"] as! [[String:Any]] {
                                dataList.append(StatusViewModel(status: Status(dict: dictionary)))
                            }
                            self.statusList = dataList
                            self.cacheSingleImage(dataList: dataList, finished: finished)
                        }
                    }
                }
            } else {
                NetworkTools.shared.loadOneStatus(id:id) { Result,Error in
                    guard let status = Result as? [String:Any] else {
                        Task { @MainActor in
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("博客加载错误", comment: ""))
                        }
                        return
                    }
                    guard let comment_list = status["comment_list"] as? [[String:Any]] else {
                        Task { @MainActor in
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("评论加载错误", comment: ""))
                        }
                        return
                    }
                    var dataList = [StatusViewModel]()
                    for dict in comment_list {
                        dataList.append(StatusViewModel(status: Status(dict: dict)))
                    }
                    self.statusList = dataList
                    self.cacheSingleImage(dataList: dataList, finished: finished)
                }
            }
        }
    }
    @MainActor private func cacheSingleImage(dataList: [StatusViewModel],finished: @escaping @Sendable @MainActor (_ isSuccessed: Bool) -> ()) {
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
                        SVProgressHUD.show(withStatus: "缓存第"+String(vm.status.id)+"图片失败")
                    }
                    
                }
            } else {
                let url = vm.thumbnailUrls![0]
                SDWebImageManager.shared.loadImage(with: url, options:[SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached],progress: nil) {
                    (image, data, error, type, bool, url) in
                    if data != nil {
                        //dataLength = dataLength + data.count
                    }
                }
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            finished(true)
        }
    }
}
