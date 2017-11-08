//  RecordDB.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import SQLite

class RecordDB {
    enum sorts: Int {
        case ACCOUNT = 1
        case CATEGORY = 2
    }

    enum timeSorts: Int {
        case ASC = 1
        case DESC = 2
    }

    static let instance = RecordDB()
    private let db: Connection?

    let accounts = Table("accounts")
    let aId = Expression<Int64>("aId")
    let aName = Expression<String>("aName")

    let categories = Table("categories")
    let cId = Expression<Int64>("cId")
    let cName = Expression<String>("cName")

    let records = Table("records")
    let rId = Expression<Int64>("rId")
    let accountId = Expression<Int64>("accountId")
    let categoryId = Expression<Int64>("categoryId")
    let amount = Expression<Double>("amount")
    let time = Expression<Int64>("time")
    let type = Expression<Int>("type")

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!

        do {
            db = try Connection("\(path)/frankG.sqlite3")
        } catch {
            db = nil
            fatalError("Unable to open database")
        }
        createTables()
    }

    func createTables() {
        do {
            try db!.run(accounts.create(ifNotExists: true) { table in
                table.column(aId, primaryKey: true)
                table.column(aName, unique: true, collate: .nocase)
            })
        } catch {
            fatalError("Unable to create accounts table")
        }

        do {
            try db!.run(categories.create(ifNotExists: true) { table in
                table.column(cId, primaryKey: true)
                table.column(cName, unique: true, collate: .nocase)
            })
        } catch {
            fatalError("Unable to create categories table")
        }

        do {
            try db!.run(records.create(ifNotExists: true) { table in
                table.column(rId, primaryKey: true)
                table.column(accountId)
                table.column(categoryId)
                table.column(amount)
                table.column(time)
                table.column(type)

            })
        } catch {
            fatalError("Unable to create records table")
        }
    }


    func getAccounts() -> [Account] {
        var accounts: [Account] = []

        do {
            for account in try db!.prepare(self.accounts.order(aName.asc)) {
                accounts.append(Account(id: account[aId], name: account[aName]))
            }
        } catch {
            fatalError("Select failed")
        }

        return accounts
    }

    func getCategories() -> [Category] {
        var categories: [Category] = []

        do {
            for category in try db!.prepare(self.categories.order(cName.asc)) {
                categories.append(Category(id: category[cId], name: category[cName]))
            }
        } catch {
            fatalError("Select failed")
        }

        return categories
    }

    func getRecords(sortBy: Int, timeAsc: Bool) -> [Record] {
        var records: [Record] = []
        var condition = self.records.join(.leftOuter, accounts, on: accountId == aId).join(.leftOuter, categories, on: categoryId == cId)

        if (timeAsc == true) {
            condition = condition.order(time.asc)
        }
        if (timeAsc == false) {
            condition = condition.order(time.desc)
        }

        if (sortBy == sorts.ACCOUNT.rawValue) {
            if (timeAsc == true) {
                condition = condition.order(aName.asc, time.asc)
            } else {
                condition = condition.order(aName.asc, time.desc)
            }
        } else if (sortBy == sorts.CATEGORY.rawValue) {
            if (timeAsc == true) {
                condition = condition.order(cName.asc, time.asc)
            } else {
                condition = condition.order(cName.asc, time.desc)
            }
        }

        do {
            for record in try db!.prepare(condition) {

                if (record[categoryId] == 0) {
                    records.append(Record(categoryId: 0, amount: record[amount], accountId: record[accountId], time: record[time], rowId: record[rId])!)
                } else {
                    records.append(Record(categoryId: record[categoryId], amount: record[amount], accountId: record[accountId], time: record[time], rowId: record[rId])!)
                }
            }
        } catch {
            fatalError("Select failed")
        }
        return records
    }

    func addAccount(name: String) {
        do {
            let insert = accounts.insert(aName <- name)
            let _ = try db!.run(insert)

        } catch {
            fatalError("Insert failed")
        }
    }

    func removeAccount(id: Int64) {
        do {
            let delete = accounts.filter(aId == id).delete()
            try db!.run(delete)
        } catch {
            fatalError("Account deletion failed")
        }
    }

    func updateAccount(id: Int64, newName: String) {
        do {
            let account = accounts.filter(aId == id)
            let update = account.update(aName <- newName)

            try db!.run(update)
        } catch {
            fatalError("Account update failed")
        }
    }

    func addCategory(name: String) {
        do {
            let insert = categories.insert(cName <- name)
            let _ = try db!.run(insert)

        } catch {
            fatalError("Insert failed")
        }
    }

    func removeCategory(id: Int64) {
        do {
            let delete = categories.filter(cId == id).delete()
            try db!.run(delete)
        } catch {
            fatalError("Category deletion failed")
        }
    }

    func updateCategory(id: Int64, newName: String) {
        do {
            let category = categories.filter(cId == id)
            let update = category.update(cName <- newName)

            try db!.run(update)
        } catch {
            fatalError("Category update failed")
        }
    }

    func addRecord(catId: Int64, accId: Int64, amount: Double, timeInMilliseconds: Int64) {
        do {

            let insert = records.insert(accountId <- accId, categoryId <- catId, self.amount <- amount, time <- timeInMilliseconds, type <- 0)
            let _ = try db!.run(insert)

        } catch {
            fatalError("Insert failed")
        }
    }

    func removeRecord(id: Int64) {
        do {
            let delete = records.filter(rId == id).delete()
            try db!.run(delete)
        } catch {
            fatalError("Record deletion failed")
        }
    }

    func updateRecord(id: Int64, newCategoryId: Int64, newAccountId: Int64, newAmount: Double, newTime: Int64, newType: Int) {

        do {
            let record = records.filter(rId == id)

            let update = record.update(accountId <- newAccountId, categoryId <- newCategoryId, amount <- newAmount, time <- newTime, type <- newType)

            try db!.run(update)
        } catch {
            fatalError("Record update failed")
        }
    }

    func getAccount(id: Int64) -> String {
        var account: String = ""

        do {
            for accountEntry in try db!.prepare(self.accounts.filter(aId == id)) {
                account = accountEntry[aName]
            }
        } catch {
            fatalError("Account search failed")
        }
        return account
    }


    func getCategory(id: Int64) -> String {
        var category: String = ""

        if (id == 0) {
            return "Category Not Specified"
        }

        do {
            for categoryEntry in try db!.prepare(self.categories.filter(cId == id)) {
                category = categoryEntry[cName]
            }
        } catch {
            fatalError("Category search failed")
        }

        return category
    }

    func searchRecordsByAccount(accountId: Int64) -> [Record] {
        var records: [Record] = []

        do {
            for record in try db!.prepare(self.records.filter(self.accountId == accountId).order(time.asc)) {
                records.append(Record(categoryId: record[self.categoryId], amount: record[amount], accountId: record[self.accountId], time: record[time], rowId: record[rId])!)
            }
        } catch {
            fatalError("Record search failed")
        }

        return records
    }

    func searchRecordsByCategory(categoryId: Int64) -> [Record] {
        var records: [Record] = []

        do {
            for record in try db!.prepare(self.records.filter(self.categoryId == categoryId).order(time.asc)) {
                records.append(Record(categoryId: record[self.categoryId], amount: record[amount], accountId: record[self.accountId], time: record[time], rowId: record[rId])!)
            }
        } catch {
            fatalError("Record search failed")
        }

        return records
    }

}
