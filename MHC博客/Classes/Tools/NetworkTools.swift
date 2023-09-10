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
    enum OAuthURL: String {
        case 登陆 = "https://mhc.lmyz6.cn/api/login.html"
        case 注册 = "https://mhc.lmyz6.cn/api/register.html"
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
        let urlString = "https://mhc.lmyz6.cn/api/accessToken.php"
        let params = ["code":code]
        request(.POST, urlString, params, finished: finished)
    }
}
extension NetworkTools {
    func loadUserInfo(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = "https://mhc.lmyz6.cn/api/getUser.php"
        request(.POST, urlString, params, finished: finished)
    }
    func loadUserInfo(uid:Int, finished: @escaping HMRequstCallBack) {
        let params = ["uid":uid]
        let urlString = "https://mhc.lmyz6.cn/api/getUserUid.php"
        request(.POST, urlString, params, finished: finished)
    }
    func trend(_ trend:String? = nil, finished: @escaping HMRequstCallBack) {
        let params = ["trend":trend]
        let urlString = "https://mhc.lmyz6.cn/api/trend.php"
        request(.GET, urlString, params, finished: finished)
    }
    func deleteTrend(_ trend:String?, finished: @escaping HMRequstCallBack) {
        let params = ["trend":trend]
        let urlString = "https://mhc.lmyz6.cn/api/deleteTrend.php"
        request(.GET, urlString, params, finished: finished)
    }
    func search(status:String, finished: @escaping HMRequstCallBack) {
        let params = ["status":status]
        let urlString = "https://mhc.lmyz6.cn/api/search.php"
        request(.POST, urlString, params, finished: finished)
    }
}
extension NetworkTools {
    func loadStatus(max_id: Int,since_id:Int,finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/api/loadBlog.php"
        var params = [String:Any]()
        if since_id > 0{
            params["since_id"] = since_id
        } else if max_id > 0{
            params["max_id"] = max_id
        }
        request(.GET, urlString, params, finished: finished)
    }
    func loadOneStatus(id: Int,finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/api/loadBlogOfId.php"
        let params = ["id":id]
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func loadHotStatus(finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/api/loadHotBlog.php"
        tokenRequest(.POST, urlString,nil, finished: finished)
    }
    func loadLikeStatus(_ uid: String,finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/api/loadLikeBlog.php"
        var params = [String:Any]()
        params["uid"] = uid
        request(.POST, urlString, params, finished: finished)
    }
    func loadCommentStatus(_ uid: String,finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/api/loadCommentBlog.php"
        var params = [String:Any]()
        params["uid"] = uid
        request(.POST, urlString, params, finished: finished)
    }
    func loadLive(finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/api/loadLive.php"
        tokenRequest(.GET, urlString, nil, finished: finished)
    }
    ///此方法已弃用，现在我们直接用blog的来加载
    /*
    func loadComment(id: Int? = nil, comment_id: Int? = nil, finished: @escaping HMRequstCallBack) {
        var params = [String:Int]()
        let urlString = "https://mhc.lmyz6.cn/api/loadComment.php"
        if comment_id != nil {
            params["comment_id"] = comment_id
        }
            params["id"] = id
        tokenRequest(.POST, urlString, params, finished: finished)
    }
     */
    func loadChat(finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["scope"]="read"
        let urlString = "https://mhc.lmyz6.cn/api/chat.php"
        request(.POST, urlString, params, finished: finished)
    }
    func loadFriend(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = "https://mhc.lmyz6.cn/api/friend.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func rename(rename: String,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["rename"] = rename
        let urlString = "https://mhc.lmyz6.cn/api/rename.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func tokenIsExpires(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = "https://mhc.lmyz6.cn/api/accessTokenIsExpires.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func ExpiresTheToken(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = "https://mhc.lmyz6.cn/api/expiresToken.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func logOff(finished: @escaping HMRequstCallBack) {
        let urlString = "https://mhc.lmyz6.cn/api/logOff.php"
        tokenRequest(.POST, urlString, nil, finished: finished)
    }
    func addFriend(_ to_uid: String,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["to_uid"] = to_uid
        let urlString = "https://mhc.lmyz6.cn/api/addFriend.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func deleteStatus(_ id: Int,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["id"] = id
        let urlString = "https://mhc.lmyz6.cn/api/deleteBlog.php"
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
        let urlString = "https://mhc.lmyz6.cn/api/addComment.php"
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
        let urlString = "https://mhc.lmyz6.cn/api/deleteComment.php"
        request(.POST, urlString, params, finished: finished)
    }
    /*
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
        let urlString = "https://mhc.lmyz6.cn/api/addLike.php"
        request(.POST, urlString, params, finished: finished)
    }
     */
    func like(_ id: Int,comment_id comment_comment_id: Int? = nil,_ comment_id: Int? = nil,_ finished: @escaping HMRequstCallBack) {
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
        let urlString = "https://mhc.lmyz6.cn/api/like.php"
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
            let urlString = "https://mhc.lmyz6.cn/api/upload.php"
            tokenRequest(.POST, urlString, params, finished: finished)
        } else {
            let urlString = "https://mhc.lmyz6.cn/api/upload.php"
            var data: [Data] = []
            for i in image! {
                data.append(i.jpegData(compressionQuality: 0.8)!)
            }
            upload(urlString, data, params) { Result, Error in
                finished(Result, Error)
            }
        }
    }
    func sendPortrait(image: UIImage?, finished: @escaping HMRequstCallBack) {
        // 1. 创建参数字典
        let params = [String: Any]()
        // 2. 设置参数
            let urlString = "https://mhc.lmyz6.cn/api/portrait.php"
            sendPortrait(urlString, image!.jpegData(compressionQuality: 0.8)!, params) { Result, Error in
                finished(Result, Error)
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
            finished(nil,error)
        }
    }
    func sendPortrait(_ URLString: String, _ data: Data, _ parameters: [String: Any]?, finished: @escaping HMRequstCallBack) {
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
            formData.appendPart(withFileData: data, name: "pic", fileName: "pic", mimeType: "image/png")
        }, progress: nil, success: { _, result in
            finished(result, nil)
        }) { _ , error in
            finished(nil,error)
        }
    }
}
