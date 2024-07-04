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
        //df.locale = Locale(identifier: "ch")
        df.dateFormat = "YYYY/MM/dd HH:mm:ss"
        return df.date(from: string)
    }
    var dateDescription: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            let delta = Int(Date().timeIntervalSince(self))
            if delta < 60 {
                return NSLocalizedString("刚刚", comment: "")
            }
            if delta < 3600 {
                return String.localizedStringWithFormat(NSLocalizedString("%@分钟前", comment: ""), String(delta / 60))
            }
            return String.localizedStringWithFormat(NSLocalizedString("%@小时前", comment: ""), String(delta / 3600))
        }
        var fmt = " HH:mm"
        let df = DateFormatter()
        if calendar.isDateInYesterday(self) {
            df.dateFormat = fmt
            return NSLocalizedString("昨天", comment: "") + df.string(from: self)
        }
        fmt = "MM-dd" + fmt
        let comps = calendar.component(.year, from: Date())
        if comps > 0 {
            fmt = "yyyy-" + fmt
        }
        df.dateFormat = fmt
        return df.string(from: self)
    }
}
