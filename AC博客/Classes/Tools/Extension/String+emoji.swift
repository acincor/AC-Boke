//
//  String+emoji.swift
//  Emoticon
//
//  Created by AC on 2022/11/10.
//

import Foundation
extension String {
    var emoji: String {
        //let scanner = Scanner(string: self)
        //let value: UInt32 = 0
        //scanner.scanHexInt32(&value)
        let chr = Character(UnicodeScalar(UInt32(String(self.dropFirst(2)), radix: 16)!)!)
        return "\(chr)"
    }
}
