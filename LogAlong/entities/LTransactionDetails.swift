//
//  LTransactionDetails.swift
//  LogAlong
//
//  Created by Michael Gao on 12/17/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LTransactionDetails: LTransaction {
    var account: LAccount
    var account2: LAccount
    var category: LCategory
    var tag: LTag
    var vendor: LVendor

    override init() {
        account = LAccount()
        account2 = LAccount()
        category = LCategory()
        tag = LTag()
        vendor = LVendor()
        super.init()
    }

    init(id: Int64, gid: Int64, rid: Int64,
         accountId: Int64, accountId2: Int64, amount: Double, type: TransactionType,
         categoryId: Int64, tagId: Int64, vendorId: Int64, note: String, by: Int64,
         timestamp: Int64,  create: Int64, access: Int64,
         account: LAccount, account2: LAccount, category: LCategory, tag: LTag, vendor: LVendor) {
        self.account = account
        self.account2 = account2
        self.category = category
        self.tag = tag
        self.vendor = vendor
        super.init(id: id, gid: gid, rid: rid, accountId: accountId, accountId2: accountId2,
                   amount: amount, type: type, categoryId: categoryId, tagId: tagId, vendorId: vendorId,
                   note: note, by: by, timestamp: timestamp, create: create, access: access)
    }
}
