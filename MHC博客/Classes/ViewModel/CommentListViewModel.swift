//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


class CommentListViewModel {
    lazy var commentList = [StatusViewModel]()
    lazy var commentCommentList = [StatusViewModel]()
    func loadComment(id: Int,finished: @escaping (_ isSuccessed: Bool) -> ()) {
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
                self.commentList = dataList
                self.cacheSingleImage(dataList: dataList, finished: finished)
            }
    }
    func loadComment(id: Int,comment_id: Int,finished: @escaping (_ isSuccessed: Bool) -> ()) {
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
                    self.commentCommentList = dataList
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
            SDWebImageManager.shared.loadImage(with: url, options:[SDWebImageOptions.retryFailed],progress: nil) {
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
