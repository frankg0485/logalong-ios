//
//  Record.swift
//  LogAlong
//
//  Created by Frank Gao on 3/11/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
class Record {

    var categoryId: Int64
    var amount: Double
    var accountId: Int64
    var time: Int64
    var rowId: Int64
    /*    var payee: String?
     var tag: String?
     var notes: String?*/

    /*    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
     static let ArchiveURL = DocumentsDirectory.appendingPathComponent("records")*/

    /*    struct PropertyKey {
     static let amount = "amount"
     static let account = "account"
     static let category = "category"
     static let payee = "payee"
     static let tag = "tag"
     static let notes = "notes"
     }
     */
    init?(categoryId: Int64, amount: Double, accountId: Int64, time: Int64, rowId: Int64/*payee: String?, tag: String?, notes: String?*/) {

        guard !(amount == 0) else {
            return nil
        }

        guard !(time == 0) else {
            return nil
        }

        self.categoryId = categoryId
        self.amount = amount
        self.accountId = accountId
        self.time = time
        self.rowId = rowId

        /*self.payee = payee ?? ""
         self.tag = tag ?? ""
         self.notes = notes ?? ""*/


    }

    /*    func encode(with aCoder: NSCoder) {
     aCoder.encode(amount, forKey: PropertyKey.amount)
     aCoder.encode(account, forKey: PropertyKey.account)
     aCoder.encode(category, forKey: PropertyKey.category)
     aCoder.encode(payee, forKey: PropertyKey.payee)
     aCoder.encode(tag, forKey: PropertyKey.tag)
     aCoder.encode(notes, forKey: PropertyKey.notes)

     }

     required convenience init?(coder aDecoder: NSCoder) {
     let amount = aDecoder.decodeFloat(forKey: PropertyKey.amount)
     guard let account = aDecoder.decodeObject(forKey: PropertyKey.account) as? String else {
     print("ERROR")
     return nil
     }

     guard let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String else {
     print("ERROR")
     return nil
     }
     guard let payee = aDecoder.decodeObject(forKey: PropertyKey.payee) as? String else {
     print("ERROR")
     return nil
     }
     guard let tag = aDecoder.decodeObject(forKey: PropertyKey.tag) as? String else {
     print("ERROR")
     return nil
     }
     guard let notes = aDecoder.decodeObject(forKey: PropertyKey.notes) as? String else {
     print("ERROR")
     return nil
     }

     self.init(category: category, amount: amount, account: account, payee: payee, tag: tag, notes: notes)


     }*/
}