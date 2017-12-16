//
//  LVendor.swift
//  LogAlong
//
//  Created by Michael Gao on 12/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

enum VendorType : UInt8 {
    case PAYEE = 10
    case PAYER = 20
    case PAYEE_PAYER = 30
}

class LVendor : LDbBase {
    var type: VendorType

    override init() {
        self.type = VendorType.PAYER
        super.init()
    }

    init(id: Int64, gid: Int64, name: String, type: VendorType, create: Int64, access: Int64) {
        self.type = type
        super.init(id: id, gid: gid, name: name, create: create, access: access)
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }

    convenience init(name: String, type: VendorType) {
        self.init(name: name)
        self.type = type
    }

    convenience init(id: Int64, gid: Int64, name: String, type: VendorType) {
        self.init(name: name, type: type)
        self.gid = gid
    }
}
