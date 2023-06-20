//
//  Date+Extension.swift
//  MHC微博
//
//  Created by mhc team on 2022/12/3.
//

import Foundation
extension Date {
    static func sina(_ string: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ch")
        df.dateFormat = "YYYY/MM/dd HH:mm:ss"
        return df.date(from: string)
    }
    var dateDescription: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            let delta = Int(Date().timeIntervalSince(self))
            if delta < 60 {
                return "刚刚"
            }
            if delta < 3600 {
                return "\(delta / 60)分钟前"
            }
            return "\(delta / 3600)小时前"
        }
        var fmt = " HH:mm"
        if calendar.isDateInYesterday(self) {
            fmt = "昨天" + fmt
        } else {
            fmt = "MM-dd" + fmt
            let comps = calendar.component(.year, from: Date())
            if comps > 0 {
                fmt = "yyyy-" + fmt
            }
        }
        let df = DateFormatter()
        df.dateFormat = fmt
        df.locale = .init(identifier: "ch")
        return df.string(from: self)
    }
}
