//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


class CommentListViewModel {
    lazy var commentList = [CommentViewModel]()
    lazy var commentCommentList = [CommentViewModel]()
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
                var dataList = [CommentViewModel]()
                for dict in comment_list {
                    dataList.append(CommentViewModel(comment: Comment(dict: dict)))
                }
                self.commentList = dataList
                finished(true)
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
            var dataList = [CommentViewModel]()
            for dict in comment_list {
                if dict["comment_id"] as! String == String(comment_id) {
                    for dictionary in dict["comment_list"] as! [[String:Any]] {
                        dataList.append(CommentViewModel(comment: Comment(dict: dictionary)))
                    }
                    self.commentCommentList = dataList
                    finished(true)
                    return
                }
            }
            
        }
    }
}
