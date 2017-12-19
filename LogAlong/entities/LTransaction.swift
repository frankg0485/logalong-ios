//
//  LTransaction.swift
//  LogAlong
//
//  Created by Frank Gao on 3/11/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import Foundation

enum TransactionType: UInt8 {
    case EXPENSE = 10
    case INCOME = 20
    case TRANSFER = 30
    case TRANSFER_COPY = 31
}

class LTransaction : LDbBase {
    var categoryId: Int64
    var tagId: Int64
    var vendorId: Int64
    var amount: Double
    var accountId: Int64
    var accountId2: Int64
    var timestamp: Int64
    var rid: Int64
    var type: TransactionType
    var note: String
    var by: Int64

    override init() {
        self.accountId = 0
        self.accountId2 = 0
        self.categoryId = 0
        self.tagId = 0
        self.vendorId = 0
        self.amount = 0
        self.timestamp = Date().currentTimeMillis
        self.type = TransactionType.EXPENSE
        self.note = ""
        self.by = 0
        self.rid = LTransaction.generateRid()
        super.init()
    }

    init(id: Int64, gid: Int64, rid: Int64,
         accountId: Int64, accountId2: Int64, amount: Double, type: TransactionType,
         categoryId: Int64, tagId: Int64, vendorId: Int64, note: String, by: Int64,
         timestamp: Int64,  create: Int64, access: Int64) {
        self.accountId = accountId;
        self.accountId2 = accountId2;
        self.categoryId = categoryId
        self.tagId = tagId
        self.vendorId = vendorId
        self.amount = amount
        self.timestamp = timestamp
        self.type = type
        self.rid = rid
        self.note = note
        self.by = by
        super.init(id: id, gid: gid, name: "", create: create, access: access)
    }

    convenience init(accountId: Int64, accountId2: Int64, amount: Double, type: TransactionType,
                     categoryId: Int64, tagId: Int64, vendorId: Int64, timestamp: Int64) {
        self.init()
        self.accountId = accountId
        self.accountId2 = accountId2
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.tagId = tagId
        self.vendorId = vendorId
        self.timestamp = timestamp
    }

    static func generateRid() -> Int64 {
        var rid = UInt64(arc4random())
        rid |= UInt64(crc32(0, data: Data(LA.toByteArray(Date().currentTimeMillis)))) << 32
        return Int64(bitPattern: rid)
    }
}
