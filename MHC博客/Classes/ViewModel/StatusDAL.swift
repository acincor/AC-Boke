//
//  StatusDAL.swift
//  MHC微博
//
//  Created by mhc team on 2022/12/3.
//

import Foundation
private let maxCacheDateTime: TimeInterval = 60
class StatusDAL {
    class func clearDataCache() {
        let date = Date(timeIntervalSinceNow: -maxCacheDateTime)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = df.string(from: date)
        let sql = "DELETE FROM T_Status WHERE createtime < '?'"
        SQLiteManager.shared.queue.inDatabase { db in
            try? db.executeUpdate(sql, values: [dateStr])
        }
    }
    class func removeCache(_ statusId: Int) {
        let sql = "DELETE FROM T_Status WHERE statusId = \(statusId)"
        SQLiteManager.shared.queue.inDatabase { db in
            try? db.executeUpdate(sql, values: nil)
        }
    }
    class func loadStatus(since_id: Int, max_id: Int, finished: @escaping(_ array: [[String:Any]]?) -> ()) {
        let array = StatusDAL.checkCacheData(since_id: since_id, max_id: max_id)
        if array!.count > 0{
            finished(array!)
            return
        }
        NetworkTools.shared.loadStatus(max_id: max_id, since_id: since_id) { (Result, Error) -> () in
            if Error != nil {
                finished(nil)
                return
            }
            guard let array = Result as? [[String: Any]] else {
                finished(nil)
                return
            }
            StatusDAL.saveCache(array: array)
            finished(array)
        }
    }
    class func checkCacheData(since_id: Int, max_id: Int) -> [[String:Any]]? {
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            return nil
        }
        var sql = "SELECT statusId, status, userId FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        let sinceCreateTime = SQLiteManager.shared.execRecordSet(sql: "SELECT create_at FROM T_Status \nWHERE statusId = \(since_id);")
        if sinceCreateTime.count != 0 && since_id > 0{
            //博客没被删除
            sql += "    AND create_at > '\(sinceCreateTime[0]["create_at"] as! String)' \n"
        }
        // 上拉刷新
        let maxCreateTime = SQLiteManager.shared.execRecordSet(sql: "SELECT create_at FROM T_Status \nWHERE statusId = \(max_id);")
        if maxCreateTime.count != 0 && max_id > 0{
            //博客没被删除
            sql += "    AND create_at < '\(maxCreateTime[0]["create_at"] as! String)' \n"
        }
        sql += "ORDER BY create_at DESC LIMIT 10;"
        let array = SQLiteManager.shared.execRecordSet(sql: sql)
        var arrayM = [[String:Any]]()
        for dict in array {
            let jsonData = dict["status"] as! Data
            let result = try! JSONSerialization.jsonObject(with: jsonData,options: [])
            arrayM.append(result as! [String:Any])
        }
        return arrayM
    }
    class func saveCache(array data: [[String:Any]]) {
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            return
        }
        let sql = "INSERT OR REPLACE INTO T_Status(statusId, status, userId, create_at) VALUES (?, ?, ?, ?);"
        
        // 3. 遍历数组 - 如果不能确认数据插入的消耗时间，可以在实际开发中写测试代码
        SQLiteManager.shared.queue.inTransaction { (db, rollback) -> Void in
            
            for dict in data {
                // 微博id
                let statusId = dict["id"] as! Int
                let create_at = dict["create_at"] as! String
                    let json = try! JSONSerialization.data(withJSONObject: dict,options: [])
                    // 插入数据
                    do {
                        try db.executeUpdate(sql, values: [statusId, json, userId, create_at])
                        guard db.changes > 0 else {
                           return
                        }
                    } catch {
                    }
            }
        }
    }
}
