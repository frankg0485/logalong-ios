//
//  LTransaction.swift
//  LogAlong
//
//  Created by Frank Gao on 3/11/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

class LTransaction : LDbBase {

    var categoryId: Int64
    var amount: Double
    var accountId: Int64
    var timestamp: Int64
    var rowId: Int64
    var type: Int

    /*    var payee: String?
     var tag: String?
     var notes: String?*/

    init?(categoryId: Int64, amount: Double, accountId: Int64, timestamp: Int64, rowId: Int64/*payee: String?, tag: String?, notes: String?*/) {
        guard !(amount == 0) else {
            return nil
        }

        guard !(timestamp == 0) else {
            return nil
        }

        self.categoryId = categoryId
        self.amount = amount
        self.accountId = accountId
        self.timestamp = timestamp
        self.rowId = rowId
        self.type = 0;

        /*self.payee = payee ?? ""
         self.tag = tag ?? ""
         self.notes = notes ?? ""*/

        super.init(name: "")
    }
}
