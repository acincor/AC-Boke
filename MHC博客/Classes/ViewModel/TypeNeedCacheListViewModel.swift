//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

class TypeNeedCacheListViewModel {
    lazy var statusList = [StatusViewModel]()
    var pulldownCount: Int?
    enum Clas: String {
        case comment = "comment"
        case quote = "quote"
    }
    var clas: Clas?
    init(clas: Clas? = nil) {
        self.clas = clas
    }
    func loadStatus(isPullup: Bool? = nil, id: Int? = nil, comment_id: Int? = nil,finished: @escaping (_ isSuccessed: Bool) -> ()) {
        if let isPullup = isPullup {
            let since_id = isPullup ? 0 : (statusList.first?.status.id ?? 0)
            let max_id = isPullup ? (statusList.last?.status.id ?? 0) : 0
            StatusDAL.loadStatus(since_id: since_id, max_id: max_id) { (array) -> () in
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
        } else if let id = id {
            if let comment_id = comment_id {
                NetworkTools.shared.loadOneStatus(id:id) { Result,Error in
                    guard let status = Result as? [String:Any] else {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("博客加载错误", comment: ""))
                        return
                    }
                    guard let comment_list = status["comment_list"] as? [[String:Any]] else {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("评论加载错误", comment: ""))
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
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("博客加载错误", comment: ""))
                        return
                    }
                    guard let comment_list = status["comment_list"] as? [[String:Any]] else {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("评论加载错误", comment: ""))
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
    private func cacheSingleImage(dataList: [StatusViewModel],finished: @escaping (_ isSuccessed: Bool) -> ()) {
        let group = DispatchGroup()
        var dataLength = 0
        for vm in dataList {
            if vm.thumbnailUrls?.count != 1 {
                continue
            }
            let url = vm.thumbnailUrls![0]
            group.enter()
            SDWebImageManager.shared.loadImage(with: url, options:[SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached],progress: nil) {
                (image, data, error, type, bool, url) in
                if let data = data {
                    dataLength = dataLength + data.count
                }
                group.leave()
            }
        }
       group.notify(queue: DispatchQueue.main) {
           NSLog("缓存\(dataLength/1024)Kb")
            finished(true)
        }
    }
}
