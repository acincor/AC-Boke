//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit


class CommentListViewModel {
    lazy var commentList = [CommentViewModel]()
    lazy var commentCommentList = [CommentCommentViewModel]()
    func loadComment(id: Int,finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.shared.loadComment(id: id) { (array,error) -> () in
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
            print(array as! [[String:Any]])
            for dict in array as! [[String:Any]]{
                dataList.append(CommentViewModel(comment: Comment(dict: dict)))
            }
            //print(dataList)
            //print("bool:",dataList.count > self.commentList.count)
            self.commentList = dataList
            //print(self.commentList)
            finished(true)
        }
    }
    func loadComment(id: Int,comment_id: Int,finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.shared.loadComment(id: id,comment_id: comment_id) { (array,error) -> () in
            print(error)
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
        }
    }
}
