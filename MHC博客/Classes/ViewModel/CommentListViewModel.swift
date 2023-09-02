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
            /*
            guard let array = array else {
                //print("数据格式错误")
                //print("array转换错误")
                finished(false)
                return
            }
            //print(id)
            //print("id:",id)
            //print("array:",array)
            var dataList = [CommentViewModel]()
            //print(array as! [[String:Any]])
            for dict in array as! [[String:Any]]{
                dataList.append(CommentViewModel(comment: Comment(dict: dict)))
                
            }
            //print(dataList)
            //print("bool:",dataList.count > self.commentList.count)
            self.commentList = dataList
            //print(self.commentList)
            finished(true)
             */
            NetworkTools.shared.loadOneStatus(id:id) { Result,Error in
                guard let status = Result as? [String:Any] else {
                    SVProgressHUD.showInfo(withStatus: "博客加载错误")
                    return
                }
                guard let comment_list = status["comment_list"] as? [[String:Any]] else {
                    SVProgressHUD.showInfo(withStatus: "评论加载错误")
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
            //print(error)
            /*
            guard let array = array else {
                //print("数据格式错误")
                //print("array转换错误")
                finished(false)
                return
            }
            //print(id)
            //print("id:",id)
            var dataList = [CommentCommentViewModel]()
            for dict in array as! [[String:Any]]{
                //print(dict)
                dataList.append(CommentCommentViewModel(comment: Comment(dict: dict)))
            }
            //print(dataList)
            //print("bool:",dataList.count > self.commentList.count)
            self.commentCommentList = dataList
            //print(self.commentList)
            finished(true)
             */
        NetworkTools.shared.loadOneStatus(id:id) { Result,Error in
            guard let status = Result as? [String:Any] else {
                SVProgressHUD.showInfo(withStatus: "博客加载错误")
                return
            }
            guard let comment_list = status["comment_list"] as? [[String:Any]] else {
                SVProgressHUD.showInfo(withStatus: "评论加载错误")
                return
            }
            var dataList = [CommentViewModel]()
            for dict in comment_list {
                if dict["comment_id"] as! String == String(comment_id) {
                    for dictionary in dict["comment_list"] as! [[String:Any]] {
                        print(dictionary)
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
