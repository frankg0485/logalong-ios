//
//  LAccount.swift
//  LogAlong
//
//  Created by Frank Gao on 9/12/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

class LAccount : LDbBase {
    var share: String
    var showBalance: Bool

    override init() {
        self.showBalance = true
        self.share = ""
        super.init()
    }

    init(id: Int64, gid: Int64, name: String, share: String, showBalance: Bool, create: Int64, access: Int64) {
        self.share = share
        self.showBalance = showBalance
        super.init(id: id, gid: gid, name: name, create: create, access: access)
    }

    convenience init(name: String, share: String, showBalance: Bool) {
        self.init()
        self.name = name
        self.share = share
        self.showBalance = showBalance
    }

    convenience init(id: Int64, name: String, share: String, showBalance: Bool) {
        self.init(name: name, share: share, showBalance: showBalance)
        self.id = id
    }

    convenience init(name: String) {
        self.init(id: 0, name: name, share: "", showBalance: true)
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
