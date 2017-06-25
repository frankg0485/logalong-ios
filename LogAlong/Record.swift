//
//  Record.swift
//  LogAlong
//
//  Created by Frank Gao on 3/11/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit
class Record: NSObject, NSCoding {

    var category: String?
    var amount: Float
    var account: String
    var payee: String?
    var tag: String?
    var notes: String?

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("records")

    struct PropertyKey {
        static let amount = "amount"
        static let account = "account"
        static let category = "category"
        static let payee = "payee"
        static let tag = "tag"
        static let notes = "notes"
    }

    init?(category: String?, amount: Float, account: String, payee: String?, tag: String?, notes: String?) {

        guard !account.isEmpty else {
            return nil
        }

        guard !(amount == 0) else {
            return nil
        }
        self.category = category ?? ""
        self.amount = amount
        self.account = account
        self.payee = payee ?? ""
        self.tag = tag ?? ""
        self.notes = notes ?? ""


    }

    func encode(with aCoder: NSCoder) {
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

        
    }
}
