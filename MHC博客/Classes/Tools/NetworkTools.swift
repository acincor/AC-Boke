//
//  NetworkTools.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/8.
//

import Foundation
class NetworkTools: AFHTTPSessionManager{
    static let shared: NetworkTools = {
        let tools = NetworkTools(baseURL: nil)
        tools.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return tools
    }()
    var tokenDict: [String: Any]? {
        if let token = UserAccountViewModel.sharedUserAccount.accessToken {
            return ["access_token": token]
        }
        return nil
    }
    enum HMRequestMethod: String {
        case GET = "GET"
        case POST = "POST"
    }
    var acceptableContentTypes: [String]?
    var OAuthURL: URL {
        let urlString = "https://mhc.lmyz6.cn/login.html"
        return URL(string: urlString)!
    }
    typealias HMRequstCallBack = (_ Result: Any?, _ Error: Error?) -> ()
}
extension NetworkTools {
    func request(_ method: HMRequestMethod, _ URLString: String, _ parameters: [String: Any]?, finished: @escaping HMRequstCallBack) {
        let success = {(task: URLSessionDataTask?, Result: Any?) -> Void in
            finished(Result,nil)
        }
        let failure = {(task: URLSessionDataTask?, Error: Error) -> Void in
            finished(nil,Error)
        }
        if method == HMRequestMethod.GET {
            get(URLString, parameters: parameters,headers: nil,progress: nil,success:success,failure: failure)
        } else {
            post(URLString, parameters: parameters, headers: nil, progress: nil,
            success: success,failure: failure)

        }
    }
    func loadAccessToken(code: String, finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/accessToken.php"
        let params = ["code":code]
        request(.POST, urlString, params, finished: finished)
        //responseSerializer = AFHTTPResponseSerializer()
        //post(urlString, parameters: params, headers: nil, progress: nil,success: { (_,Result) -> Void in
            //let json = NSString(data: Result as! Data, encoding: String.Encoding.utf8.rawValue)
            //print(json)
        //},failure: nil)
    }
}
extension NetworkTools {
    func loadUserInfo(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = "https://mhc.lmyz6.cn/getUser.php"
        request(.POST, urlString, params, finished: finished)
    }
}
extension NetworkTools {
    func loadStatus(finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/loadBlog.php"
        tokenRequest(.GET, urlString, nil, finished: finished)
    }
    func loadComment(id: Int? = nil, comment_id: Int? = nil, finished: @escaping HMRequstCallBack) {
        var params = [String:Int]()
        let urlString = "https://mhc.lmyz6.cn/loadComment.php"
        if comment_id != nil {
            params["comment_id"] = comment_id
        }
            params["id"] = id
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func loadChat(finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["scope"]="read"
        let urlString = "https://mhc.lmyz6.cn/chat.php"
        request(.POST, urlString, params, finished: finished)
    }
    func loadFriend(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = "https://mhc.lmyz6.cn/friend.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func addFriend(_ to_user: String,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["to_user"] = to_user
        let urlString = "https://mhc.lmyz6.cn/addFriend.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func deleteStatus(_ id: Int,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["id"] = id
        let urlString = "https://mhc.lmyz6.cn/deleteBlog.php"
        request(.POST, urlString, params, finished: finished)
    }
    func addComment(id: Int, comment_id: Int? = nil,_ comment: String,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        if comment_id != nil {
            params["comment_id"] = comment_id
        }
        params["id"] = id
        params["comment"] = comment
        //print(params)
        let urlString = "https://mhc.lmyz6.cn/addComment.php"
        request(.POST, urlString, params, finished: finished)
    }
    func deleteComment(_ id: Int,_ comment_id: Int,comment_id comment_comment_id: Int? = nil,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["id"] = id
        params["comment_id"] = comment_id
        if comment_comment_id != nil {
            params["to_comment_id"] = comment_id
            params["comment_id"] = comment_comment_id
        }
        print(params)
        let urlString = "https://mhc.lmyz6.cn/deleteComment.php"
        request(.POST, urlString, params, finished: finished)
    }
    func addLike(_ id: Int,_ comment_id: Int? = nil,comment_id comment_comment_id: Int? = nil,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        if comment_id != nil {
            params["comment_id"] = comment_id
        }
        if comment_comment_id != nil {
            params["to_comment_id"] = comment_comment_id
        }
        params["id"] = id
        let urlString = "https://mhc.lmyz6.cn/addLike.php"
        request(.POST, urlString, params, finished: finished)
    }
    func deleteLike(_ id: Int,comment_id comment_comment_id: Int? = nil,_ comment_id: Int? = nil,_ finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["id"] = id
        params["like_uid"] = UserAccountViewModel.sharedUserAccount.account!.uid!
        if comment_id != nil {
            params["like_comment_id"] = comment_id
        }
        if comment_comment_id != nil {
            params["to_comment_id"] = comment_comment_id
        }
        let urlString = "https://mhc.lmyz6.cn/deleteLike.php"
        request(.POST, urlString, params, finished: finished)
    }
    func tokenRequest(_ method: HMRequestMethod, _ URLString: String, _ parameters: [String: Any]?, finished: @escaping HMRequstCallBack) {
        guard let token = UserAccountViewModel.sharedUserAccount.accessToken else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token为空"]))
            return
        }
        var parameters = parameters
        if parameters == nil {
            parameters = [String: Any]()
        }
        parameters!["access_token"] = token
        request(method, URLString, parameters, finished: finished)
    }
}
extension NetworkTools {
    func sendStatus(status: String,image: [UIImage]?, finished: @escaping HMRequstCallBack) {
        // 1. 创建参数字典
        var params = [String: Any]()
        // 2. 设置参数
        params["status"] = status
        if image == nil {
            let urlString = "https://mhc.lmyz6.cn/upload.php"
            tokenRequest(.POST, urlString, params, finished: finished)
        } else {
            let urlString = "https://mhc.lmyz6.cn/upload.php"
            var data: [Data] = []
            for i in image! {
                data.append(i.jpegData(compressionQuality: 0.8)!)
            }
            upload(urlString, data, params) { Result, Error in
                finished(Result, Error)
            }
        }
    }
    private func upload(_ URLString: String, _ data: [Data], _ parameters: [String: Any]?, finished: @escaping HMRequstCallBack) {
        guard let token = UserAccountViewModel.sharedUserAccount.accessToken else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            
            return
        }
        var parameters = parameters
        if parameters == nil {
            parameters = [String:Any]()
        }
        parameters!["access_token"] = token
        post(URLString, parameters: parameters,headers: nil,constructingBodyWith: { formData in
            for d in 0...data.count - 1{
                formData.appendPart(withFileData: data[d], name: "pic{number}".replacingOccurrences(of: "{number}", with: String(d)), fileName: "pic{number}".replacingOccurrences(of: "{number}", with: String(d)), mimeType: "image/png")
            }
        }, progress: nil, success: { _, result in
            finished(result, nil)
        }) { _ , error in
            //print(error)
            finished(nil,error)
        }
    }
}
