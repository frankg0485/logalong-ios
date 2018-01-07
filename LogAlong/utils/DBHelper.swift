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
    let accountBalances = Table("LAccountBalance")
    let categories = Table("LCategory")
    let tags = Table("LTag")
    let vendors = Table("LVendor")
    let vendorCategories = Table("LVendorCategory")
    let transactions = Table("LTransaction")
    let scheduledTransactions = Table("LScheduledTransactions")
    let journals = Table("LJournal")

    static let id = Expression<Int64>("Id")
    static let gid = Expression<Int64>("Gid")
    static let rid = Expression<Int64>("Rid")
    static let name = Expression<String?>("Name")
    static let accountId = Expression<Int64>("AccountId")
    static let accountId2 = Expression<Int64>("AccountId2")
    static let categoryId = Expression<Int64>("CategoryId")
    static let tagId = Expression<Int64>("TagId")
    static let vendorId = Expression<Int64>("VendorId")
    static let amount = Expression<Double>("Amount")
    static let note = Expression<String>("Note")
    static let timestamp = Expression<Int64>("Timestamp")
    static let timestampCretae = Expression<Int64>("TimestampCreate")
    static let timestampAccess = Expression<Int64>("TimestampAccess")
    static let type = Expression<Int>("Type")
    static let showBalance = Expression<Int>("ShowBalance")
    static let icon = Expression<Data?>("Icon")
    static let share = Expression<String>("Share")
    static let enable = Expression<Int>("Enable")
    static let repeatCount = Expression<Int>("RepeatCount")
    static let repeatInterval = Expression<Int>("RepeatInterval")
    static let repeatUnit = Expression<Int>("RepeatUnit")
    static let scheduleTime = Expression<Int64>("ScheduleTime")
    static let year = Expression<Int>("Year")
    static let balance = Expression<String>("Balance")
    static let by = Expression<Int64>("By")

    static let journalId = Expression<Int>("JournalId")
    static let data = Expression<Data>("Data")

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
                table.column(DBHelper.gid)
                table.column(DBHelper.name, unique: true, collate: .nocase)
                table.column(DBHelper.share)
                table.column(DBHelper.timestampCretae)
                table.column(DBHelper.timestampAccess)
                table.column(DBHelper.showBalance)
                table.column(DBHelper.icon)
            })
        } catch {
            LLog.e("\(self)", "Unable to create accounts table")
        }

        do {
            try db!.run(accountBalances.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.accountId)
                table.column(DBHelper.year)
                table.column(DBHelper.balance)
            })
        } catch {
            LLog.e("\(self)", "Unable to create account balances table")
        }

        do {
            try db!.run(categories.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.gid)
                table.column(DBHelper.name, unique: true, collate: .nocase)
                table.column(DBHelper.timestampCretae)
                table.column(DBHelper.timestampAccess)
                table.column(DBHelper.icon)
            })
        } catch {
            LLog.e("\(self)", "Unable to create categories table")
        }

        do {
            try db!.run(tags.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.gid)
                table.column(DBHelper.name, unique: true, collate: .nocase)
                table.column(DBHelper.timestampCretae)
                table.column(DBHelper.timestampAccess)
                table.column(DBHelper.icon)
            })
        } catch {
            LLog.e("\(self)", "Unable to create tags table")
        }

        do {
            try db!.run(vendors.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.gid)
                table.column(DBHelper.name, unique: true, collate: .nocase)
                table.column(DBHelper.type)
                table.column(DBHelper.timestampCretae)
                table.column(DBHelper.timestampAccess)
                table.column(DBHelper.icon)
            })
        } catch {
            LLog.e("\(self)", "Unable to create vendor table")
        }

        do {
            try db!.run(vendorCategories.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.vendorId)
                table.column(DBHelper.categoryId)
            })
        } catch {
            LLog.e("\(self)", "Unable to create vendor categories table")
        }

        do {
            try db!.run(transactions.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.gid)
                table.column(DBHelper.accountId)
                table.column(DBHelper.accountId2)
                table.column(DBHelper.categoryId)
                table.column(DBHelper.tagId)
                table.column(DBHelper.vendorId)
                table.column(DBHelper.amount)
                table.column(DBHelper.timestamp)
                table.column(DBHelper.type)
                table.column(DBHelper.note)
                table.column(DBHelper.by)
                table.column(DBHelper.rid)
                table.column(DBHelper.timestampCretae)
                table.column(DBHelper.timestampAccess)
                table.column(DBHelper.icon)
            })
        } catch {
            LLog.e("\(self)", "Unable to create transactions table")
        }

        do {
            try db!.run(scheduledTransactions.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.gid)
                table.column(DBHelper.accountId)
                table.column(DBHelper.accountId2)
                table.column(DBHelper.categoryId)
                table.column(DBHelper.tagId)
                table.column(DBHelper.vendorId)
                table.column(DBHelper.amount)
                table.column(DBHelper.timestamp)
                table.column(DBHelper.type)
                table.column(DBHelper.note)
                table.column(DBHelper.by)
                table.column(DBHelper.rid)
                table.column(DBHelper.timestampCretae)
                table.column(DBHelper.timestampAccess)
                table.column(DBHelper.icon)

                table.column(DBHelper.enable)
                table.column(DBHelper.repeatUnit)
                table.column(DBHelper.repeatCount)
                table.column(DBHelper.repeatInterval)
                table.column(DBHelper.scheduleTime)
            })
        } catch {
            LLog.e("\(self)", "Unable to create scheduled transactions table")
        }

        do {
            try db!.run(journals.create(ifNotExists: true) { table in
                table.column(DBHelper.id, primaryKey: true)
                table.column(DBHelper.journalId)
                table.column(DBHelper.data, defaultValue: nil)
            })
        } catch {
            LLog.e("\(self)", "Unable to create journals table")
        }
    }
}
