//
//  LDbBase.swift
//  LogAlong
//
//  Created by Michael Gao on 11/29/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import Foundation

class LDbBase {
    var id: Int64
    var gid: Int64
    var timestampCreate: Int64
    var timestampAccess: Int64
    var name: String

    init() {
        self.id = 0
        self.gid = 0
        self.name = ""
        self.timestampCreate = Date().currentTimeMillis
        self.timestampAccess = self.timestampCreate
    }

    init(id: Int64, gid: Int64, name: String, create: Int64, access: Int64) {
        self.id = id
        self.gid = gid
        self.name = name
        self.timestampCreate = create
        self.timestampAccess = access
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }

    convenience init(id: Int64, name: String) {
        self.init(name: name)
        self.id = id
    }

    convenience init(id: Int64, gid: Int64, name: String) {
        self.init(id: id, name: name)
        self.gid = gid
    }
}
