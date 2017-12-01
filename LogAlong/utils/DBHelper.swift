//
//  DBConnection.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import SQLite

class DBHelper {
    static let instance = DBHelper()
    let db: Connection?

    let accounts = Table("LAccount")
    let categories = Table("LCategory")
    let transactions = Table("LTransaction")

    static let id = Expression<Int64>("Id")
    static let name = Expression<String>("Name")
    static let accountId = Expression<Int64>("AccountId")
    static let categoryId = Expression<Int64>("CategoryId")
    static let amount = Expression<Double>("Amount")
    static let timestamp = Expression<Int64>("Timestamp")
    static let type = Expression<Int>("Type")

    init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!

        do {
            db = try Connection("\(path)/logalong.sqlite3")
        } catch {
            db = nil
            LLog.e("\(self)", "Unable to open database")
        }
        createTables()
    }

    func createTables() {
        do {
            try db!.run(accounts.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.name, unique: true, collate: .nocase)
            })
        } catch {
            LLog.e("\(self)", "Unable to create accounts table")
        }

        do {
            try db!.run(categories.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.name, unique: true, collate: .nocase)
            })
        } catch {
            LLog.e("\(self)", "Unable to create categories table")
        }

        do {
            try db!.run(transactions.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.accountId)
                table.column(DBHelper.categoryId)
                table.column(DBHelper.amount)
                table.column(DBHelper.timestamp)
                table.column(DBHelper.type)
            })
        } catch {
            LLog.e("\(self)", "Unable to create records table")
        }
    }
}
