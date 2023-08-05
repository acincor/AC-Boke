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
        //print(date)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = df.string(from: date)
        //print(dateStr)
        let sql = "DELETE FROM T_Status WHERE createtime < '?'"
        //DELETE FROM T_Status WHERE createTime < (?);
        SQLiteManager.shared.queue.inDatabase { db in
            try? db.executeUpdate(sql, values: [dateStr])
            if db.changes > 0 {
                //print("删除了\(db.changes)条缓存数据")
            } else {
                //print("没有需要删除的")
            }
        }
    }
    class func loadStatus(since_id: Int, max_id: Int, finished: @escaping(_ array: [[String:Any]]?) -> ()) {
        let array = StatusDAL.checkCacheData(since_id: since_id, max_id: max_id)
        if array!.count > 0{
            //print("查询到缓存数据 \(array!.count)")
            finished(array!)
            return
        }
        NetworkTools.shared.loadStatus { (Result, Error) -> () in
            if Error != nil {
                //print("出错了")
                finished(nil)
                return
            }
            guard let array = Result as? [[String: Any]] else {
                //print("数据格式错误")
                finished(nil)
                return
            }
            StatusDAL.saveCache(array: array)
            finished(array)
        }
    }
    class func checkCacheData(since_id: Int, max_id: Int) -> [[String:Any]]? {
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            //print("用户没有登录")
            return nil
        }
        var sql = "SELECT statusId, status, userId FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        if since_id > 0 {
            sql += "    AND statusId > \(since_id) \n"
        } else if max_id > 0 {
            sql += "    AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 10;"
        //print("查询数据 SQL -> "+sql)
        let array = SQLiteManager.shared.execRecordSet(sql: sql)
        var arrayM = [[String:Any]]()
        for dict in array {
            let jsonData = dict["status"] as! Data
            let result = try! JSONSerialization.data(withJSONObject: jsonData,options: [])
            arrayM.append(result as! [String:Any])
        }
        return arrayM
    }
    class func saveCache(array data: [[String:Any]]) {
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            //print("用户没有登录")
            return
        }
        let sql = "INSERT OR REPLACE INTO T_Status(statusId, status, userId) VALUES (?, ?, ?);"
        
        // 3. 遍历数组 - 如果不能确认数据插入的消耗时间，可以在实际开发中写测试代码
        SQLiteManager.shared.queue.inTransaction { (db, rollback) -> Void in
            
            for dict in data {
                // 微博id
                let statusId = dict["id"] as! Int
                
                // 序列化字典 -> 二进制数据
                let json = try! JSONSerialization.data(withJSONObject: dict,options: [])
                
                // 插入数据
                do {
                    try db.executeUpdate(sql, values: [statusId, json, userId])
                    guard db.changes > 0 else {
                        //print("插入数据失败")
                        break
                    }
                } catch {
                    //print("插入数据成功")
                }
            }
        }
        //print("数据插入完成")
    }
}
