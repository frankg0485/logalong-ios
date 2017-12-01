//
//  LDbBase.swift
//  LogAlong
//
//  Created by Michael Gao on 11/29/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

class LDbBase {
    var id: Int64
    var gid: Int64
    var name: String

    init(id: Int64, gid: Int64, name: String) {
        self.id = id
        self.gid = gid
        self.name = name
    }

    init(id: Int64, name: String) {
        self.id = id
        self.name = name
        self.gid = 0
    }

    init(name: String) {
        self.name = name
        self.id = 0
        self.gid = 0
    }
}
