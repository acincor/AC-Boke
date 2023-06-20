//
//  String+emoji.swift
//  Emoticon
//
//  Created by mhc team on 2022/11/10.
//

import Foundation
extension String {
    var emoji: String {
        let scanner = Scanner(string: self)
        var value: UInt32 = 0
        scanner.scanHexInt32(&value)
        let chr = Character(UnicodeScalar(value)!)
        return "\(chr)"
    }
}
