//
//  StatusDAL.swift
//  MHC微博
//
//  Created by mhc team on 2022/12/3.
//

import Foundation
private let maxCacheDateTime: TimeInterval = 60
class ChatDAL {
    class func clearDataCache() {
        let date = Date(timeIntervalSinceNow: -maxCacheDateTime)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        _ = df.string(from: date)
        let sql = "DELETE FROM T_Chats;"
        SQLiteManager.shared.chatQueue.inDatabase { db in
            try? db.executeUpdate(sql, values: nil)
        }
    }
    class func ChatStatus(to_uid: Int,finished: @escaping(_ array: [[String:Any]]?)->()){
        let sql = "DELETE FROM T_Chats WHERE content = '';"
        
        // 3. 遍历数组 - 如果不能确认数据插入的消耗时间，可以在实际开发中写测试代码
        SQLiteManager.shared.chatQueue.inTransaction { (db, rollback) -> Void in
            do{
                try db.executeQuery(sql, values: nil)
            } catch{
            }
        }
        guard let array = ChatDAL.checkCacheData(to_uid: to_uid) else {
            finished(nil)
            return
        }
            if array.count > 0{
                finished(array)
            }
    }
    class func checkCacheData(to_uid: Int) -> [[String:Any]]? {
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            return nil
        }
        var sql = "SELECT to_uid, content, userId, timeInterval FROM T_Chats \n"
        sql += "WHERE userId = \(userId) \n"
        sql += "    AND to_uid = \(to_uid) \n"
        let array = SQLiteManager.shared.chatExecRecordSet(sql: sql)
        sql = "SELECT to_uid, content, userId, timeInterval FROM T_Chats \n"
        sql += "WHERE userId = \(to_uid) \n"
        sql += "    AND to_uid = \(userId) \n"
        let to_uidArray = SQLiteManager.shared.chatExecRecordSet(sql: sql)
        var arrayM = [[String:Any]]()
        for dict in array {
            arrayM.append(dict)
        }
        for dict in to_uidArray {
            arrayM.append(dict)
        }
        return arrayM
    }
    class func saveCache(array data: [String:Any]) {
        let sql = "INSERT INTO T_Chats(to_uid, content, timeInterval, userId) VALUES (?, ?, ?, ?);"
        
        // 3. 遍历数组 - 如果不能确认数据插入的消耗时间，可以在实际开发中写测试代码
        SQLiteManager.shared.chatQueue.inTransaction { (db, rollback) -> Void in
            
            // 微博id
            let userId = data["uid"] as! Int
            
            let to_uid = data["to_uid"] as! Int
            
            let timeInterval = data["timeInterval"] as! TimeInterval
            
            // 序列化字典 -> 二进制数据
            
            // 插入数据
            do {
                try db.executeUpdate(sql, values: [to_uid, data["content"] as! String, timeInterval, userId])
                guard db.changes > 0 else {
                    return
                }
            } catch {
            }
        }
    }
}
