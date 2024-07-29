//
//  NetworkTools.swift
//  AC博客
//
//  Created by AC on 2022/9/8.
//

import Foundation

class NetworkTools{
    static let shared: NetworkTools = {
        let tools = NetworkTools()
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
    typealias HMRequstCallBack = (_ Result: Any?, _ Error: Error?) -> ()
}
extension NetworkTools {
    func request(_ method: HMRequestMethod, _ URLString: String, _ parameters: [String: Any]?, finished: @escaping HMRequstCallBack) {
        let completion = {(task: AFDataResponse<Data?>) -> Void in
            if let any = try? JSONSerialization.jsonObject(with: task.data ?? Data(), options: .allowFragments){
                if let dict = any as? [[String: Any]] {
                    finished(dict,task.error)
                }
                if let dict = any as? [String: Any] {
                    finished(dict,task.error)
                }
                return
            }
            finished(task.data,task.error)
        }
        if method == HMRequestMethod.GET {
            AF.request(URLString,method: .get, parameters: parameters, headers: HTTPHeaders([HTTPHeader(name: "Accept", value: "text/plain")]))
                .response(completionHandler: completion)
            
        } else {
            AF.request(URLString,method: .post, parameters: parameters, headers: HTTPHeaders([HTTPHeader(name: "Accept", value: "text/plain")]))
                .response(completionHandler: completion)

        }
    }
    func loadAccessToken(code: String, finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/accessToken.php"
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
        let urlString = rootHost+"/api/getUser.php"
        request(.POST, urlString, params, finished: finished)
    }
    func loadUserInfo(uid:Int, finished: @escaping HMRequstCallBack) {
        let params = ["uid":uid]
        let urlString = rootHost+"/api/getUserUid.php"
        request(.POST, urlString, params, finished: finished)
    }
    func trend(_ trend:String? = nil, finished: @escaping HMRequstCallBack) {
        let params = ["trend":trend]
        let urlString = rootHost+"/api/trend.php"
        tokenRequest(.GET, urlString, params as [String : Any], finished: finished)
    }
    func deleteTrend(_ trend:String?, finished: @escaping HMRequstCallBack) {
        let params = ["trend":trend]
        let urlString = rootHost+"/api/deleteTrend.php"
        tokenRequest(.GET, urlString, params as [String : Any], finished: finished)
    }
    func search(status:String, finished: @escaping HMRequstCallBack) {
        let params = ["status":status]
        let urlString = rootHost+"/api/search.php"
        request(.POST, urlString, params, finished: finished)
    }
}
extension NetworkTools {
    func loadStatus(max_id: Int,since_id:Int,finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/loadBlog.php"
        var params = [String:Any]()
        if since_id > 0{
            params["since_id"] = since_id
        } else if max_id > 0{
            params["max_id"] = max_id
        }
        tokenRequest(.GET, urlString, params, finished: finished)
    }
    func profile(uid: String,finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/profileBlog.php"
        let params = ["uid":uid]
        request(.GET, urlString, params, finished: finished)
    }
    func loadOneStatus(id: Int,finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/loadBlogOfId.php"
        let params = ["id":id]
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func loadHotStatus(finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/loadHotBlog.php"
        tokenRequest(.POST, urlString,nil, finished: finished)
    }
    func loadLikeStatus(_ uid: String,finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/loadLikeBlog.php"
        var params = [String:Any]()
        params["uid"] = uid
        request(.POST, urlString, params, finished: finished)
    }
    func loadCommentStatus(_ uid: String,finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/loadCommentBlog.php"
        var params = [String:Any]()
        params["uid"] = uid
        request(.POST, urlString, params, finished: finished)
    }
    func loadLive(finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/loadLive.php"
        tokenRequest(.GET, urlString, nil, finished: finished)
    }
    func loadFriend(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = rootHost+"/api/friend.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func rename(rename: String,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["rename"] = rename
        let urlString = rootHost+"/api/rename.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func tokenIsExpires(finished: @escaping HMRequstCallBack) {
        guard let params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        let urlString = rootHost+"/api/accessTokenIsExpires.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func ExpiresTheToken(finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/expiresToken.php"
        tokenRequest(.POST, urlString, nil, finished: finished)
    }
    func logOff(finished: @escaping HMRequstCallBack) {
        let urlString = rootHost+"/api/logOff.php"
        tokenRequest(.POST, urlString, nil, finished: finished)
    }
    func addFriend(_ to_uid: String,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["to_uid"] = to_uid
        let urlString = rootHost+"/api/addFriend.php"
        tokenRequest(.POST, urlString, params, finished: finished)
    }
    func deleteStatus(_ comment_id: Int?,_ comment_comment_id: Int?,_ id: Int,finished: @escaping HMRequstCallBack) {
        guard var params = tokenDict else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            return
        }
        params["id"] = id
        if(comment_id != nil) {
            params["comment_id"] = comment_id
            if comment_comment_id != nil {
                params["to_comment_id"] = comment_id
                params["comment_id"] = comment_comment_id
            }
        }
        let urlString = rootHost+"/api/deleteBlog.php"
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
        let urlString = rootHost+"/api/addLike.php"
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
        let urlString = rootHost+"/api/like.php"
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
    func sendStatus(status: String,comment_id: Int?,id: Int?,image: [UIImage], finished: @escaping HMRequstCallBack) {
        // 1. 创建参数字典
        var params = [String: Any]()
        // 2. 设置参数
        let urlString = rootHost+"/api/upload.php"
        if let id = id{
            if comment_id != nil {
                params["comment_id"] = comment_id
            }
            params["id"] = id
            params["comment"] = status
        } else {
            params["status"] = status
        }
        var data: [Data] = []
        for i in image {
            data.append(i.sd_imageData()!)
        }
        upload(urlString, data, params,finished: finished)
    }
    func sendPortrait(image: UIImage?, finished: @escaping HMRequstCallBack) {
        // 1. 创建参数字典
        let params = [String: Any]()
        // 2. 设置参数
            let urlString = rootHost+"/api/portrait.php"
            sendPortrait(urlString, image!.jpegData(compressionQuality: 0.8)!, params) { Result, Error in
                finished(Result, Error)
            }
    }
    private func upload(_ URLString: String, _ data: [Data], _ parameters: Parameters?, finished: @escaping HMRequstCallBack) {
        guard let token = UserAccountViewModel.sharedUserAccount.accessToken else {
            finished(nil, NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            
            return
        }
        var parameters = parameters
        if parameters == nil {
            parameters = [String:Any]()
        }
        parameters!["access_token"] = token
        let completion = {(task: AFDataResponse<Data?>) -> Void in
            finished(task.data,task.error)
        }
        AF.upload(multipartFormData: { formData in
            for d in 0..<data.count{
                formData.append(data[d], withName: "pic{number}".replacingOccurrences(of: "{number}", with: String(d)), fileName: "pic{number}".replacingOccurrences(of: "{number}", with: String(d)),mimeType: data[d].detectImageType().0.rawValue)
            }
            for (key,value) in parameters ?? [:]{
                formData.append("\(value)".data(using: .utf8)!, withName: key)
            }
        }, to: URLString)
            .response(completionHandler: completion)
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
        let completion = {(task: AFDataResponse<Data?>) -> Void in
            finished(task.data,task.error)
        }
        AF.upload(multipartFormData: { formData in
            formData.append(data, withName: "pic", fileName: "pic", mimeType: data.detectImageType().0.rawValue)
            for (key,value) in parameters ?? [:]{
                formData.append("\(value)".data(using: .utf8)!, withName: key)
            }
        }, to: URLString)
            .response(completionHandler: completion)
    }
}

    extension Data {
        enum ImageType: String {
            case unknown = "unknown"
            case jpeg = "image/jpeg"
            case jpeg2000 = "image/jp2"
            case tiff = "image/tiff"
            case bmp = "image/bmp"
            case ico = "image/vnd.microsoft.icon"
            case icns = "image/x-icon"
            case gif = "image/gif"
            case png = "image/png"
            case webp = "image/webp"
        }
        enum Extended: String {
            case unknown = ""
            case jpeg = "jpeg"
            case jpeg2000 = "jp2"
            case tiff = "tiff"
            case bmp = "bmp"
            case ico = "ico"
            case icns = "icns"
            case gif = "gif"
            case png = "png"
            case webp = "webp"
        }
        func detectImageType() -> (Data.ImageType,Data.Extended) {
            if self.count < 16 { return (.unknown,.unknown) }
            
            var value = [UInt8](repeating:0, count:1)
            
            self.copyBytes(to: &value, count: 1)
            
            switch value[0] {
            case 0x4D, 0x49:
                return (.tiff,.tiff)
            case 0x00:
                return (.ico,.ico)
            case 0x69:
                return (.icns,.icns)
            case 0x47:
                return (.gif,.gif)
            case 0x89:
                return (.png,.png)
            case 0xFF:
                return (.jpeg,.jpeg)
            case 0x42:
                return (.bmp,.bmp)
            case 0x52:
                let subData = self.subdata(in: Range(NSMakeRange(0, 12))!)
                if let infoString = String(data: subData, encoding: .ascii) {
                    if infoString.hasPrefix("RIFF") && infoString.hasSuffix("WEBP") {
                        return (.webp,.webp)
                    }
                }
                break
            default:
                break
            }
            
            return (.unknown,.unknown)
        }
        
        static func detectImageType(with url: URL) -> (Data.ImageType,Data.Extended) {
            if let data = try? Data(contentsOf: url) {
                return data.detectImageType()
            } else {
                return (.unknown,.unknown)
            }
        }
        
        static func detectImageType(with filePath: String) -> (Data.ImageType,Data.Extended) {
            let pathUrl = URL(fileURLWithPath: filePath)
            if let data = try? Data(contentsOf: pathUrl) {
                return data.detectImageType()
            } else {
                return (.unknown,.unknown)
            }
        }
        
        static func detectImageType(with imageName: String, bundle: Bundle = Bundle.main) -> (Data.ImageType?,Data.Extended?) {
            
            guard let path = bundle.path(forResource: imageName, ofType: "") else { return (nil,nil) }
            let pathUrl = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: pathUrl) {
                return data.detectImageType()
            } else {
                return (nil,nil)
            }
        }
        
        
    }
