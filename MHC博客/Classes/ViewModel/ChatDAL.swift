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
        //print(date)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = df.string(from: date)
        //print(dateStr)
        let sql = "DELETE FROM T_Chats;"
        //DELETE FROM T_Status WHERE createTime < (?);
        SQLiteManager.shared.chatQueue.inDatabase { db in
            try? db.executeUpdate(sql, values: nil)
            if db.changes > 0 {
                //print("删除了\(db.changes)条缓存数据")
            } else {
                //print("没有需要删除的")
            }
        }
    }
    class func ChatStatus(to_uid: Int,finished: @escaping(_ array: [[String:Any]]?)->()){
        let sql = "DELETE FROM T_Chats WHERE content = '';"
        
        // 3. 遍历数组 - 如果不能确认数据插入的消耗时间，可以在实际开发中写测试代码
        SQLiteManager.shared.chatQueue.inTransaction { (db, rollback) -> Void in
            do{
                try db.executeQuery(sql, values: nil)
                //print("数据去空完成")
            } catch{
                //print("数据去空失败")
            }
        }
        guard let array = ChatDAL.checkCacheData(to_uid: to_uid) else {
            finished(nil)
            return
        }
        //print(array)
            if array.count > 0{
                //print("查询到缓存数据 \(array.count)")
                finished(array)
            }
    }
    class func checkCacheData(to_uid: Int) -> [[String:Any]]? {
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            //print("用户没有登录")
            return nil
        }
        var sql = "SELECT to_uid, content, userId, timeInterval FROM T_Chats \n"
        sql += "WHERE userId = \(userId) \n"
        sql += "    AND to_uid = \(to_uid) \n"
        //print("查询数据 SQL -> "+sql)
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
                    //print("插入数据失败")
                    return
                }
            } catch {
                //print("插入数据成功")
            }
        }
        //print("数据插入完成")
    }
}
