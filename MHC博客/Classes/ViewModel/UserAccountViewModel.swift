//
//  UserAccountViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/10.
//

import Foundation

class UserAccountViewModel {
    var portraitUrl: URL {
        let 中文转换过的url = account!.portrait?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string: 中文转换过的url ?? "")!
    }
    static let sharedUserAccount = UserAccountViewModel()
    var account: UserAccount?
    var userLogon: Bool {
        return account?.access_token != nil
    }
    var accessToken: String? {
        return account?.access_token
    }
    private var accountPath: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        //print(path)
        return (path as NSString).appendingPathComponent("account.plist")
    }
    private init() {
        account = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath) as? UserAccount
        //print(account)
    }
}
extension UserAccountViewModel {
    func loadAccessToken(code: String, finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.shared.loadAccessToken(code: code) { (Result, Error) -> () in
            if Error != nil {
                //print(Error)
                //print("出错了")
                finished(false)
                return
            }
            ////print(Result)
            self.account = UserAccount(dict: Result as! [String: Any])
            self.loadUserInfo(account: self.account!, finished: finished)
        }
    }
    func loadUserInfo(account: UserAccount, finished: @escaping (_ isSuccessed: Bool) -> ()) {
        NetworkTools.shared.loadUserInfo { (Result, Error) -> () in
            if Error != nil {
                //print("加载用户出错了")
                finished(false)
                return
            }
            guard let dict = Result as? [String: Any] else {
                //print("格式错误")
                finished(false)
                return
            }
            account.user = dict["user"] as? String
            account.portrait = (dict["portrait"] as? String)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            account.uid = dict["uid"] as? String
            NSKeyedArchiver.archiveRootObject(account, toFile: self.accountPath)
            //print(self.accountPath)
            finished(true)
        }
    }
}
