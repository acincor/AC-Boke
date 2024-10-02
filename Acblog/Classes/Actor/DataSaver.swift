//
//  Data.swift
//  Acblog
//
//  Created by Monkey hammer on 10/2/24.
//

actor DataSaver {
    static var data: Any?
    static func get() -> Any? {
        return data
    }
    static func set(data: Any?) {
        self.data = data
    }
}
