//
//  RecordDB.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
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
            print ("Unable to open database")
        }

        createTables()
    }

    func createTables() {
        do {
            try db!.run(accounts.create(ifNotExists: true) { table in
                table.column(aId, primaryKey: true)
                table.column(aName)
            })
        } catch {
            print("Unable to create accounts table")
        }

        do {
            try db!.run(categories.create(ifNotExists: true) { table in
                table.column(cId, primaryKey: true)
                table.column(cName)
            })
        } catch {
            print("Unable to create categories table")

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
            print("Unable to create records table")

        }
    }


    func getAccounts() -> [String] {
        var accounts = [String]()

        do {

            for account in try db!.prepare(self.accounts.order(aName.asc)) {
                accounts.append(account[aName])
            }
        } catch {
            print("Select failed")
        }

        return accounts
    }

    func getCategories() -> [String] {
        var categories = [String]()

        do {

            for category in try db!.prepare(self.categories.order(cName.asc)) {
                categories.append(category[cName])
            }
        } catch {
            print("Select failed")
        }

        return categories
    }

    func getRecords(sortBy: Int) -> [Record] {
        var records: [Record] = []
        var condition = self.records.join(.leftOuter, accounts, on: accountId == aId).order(time.asc)

        if (sortBy == sorts.ACCOUNT.rawValue) {
            condition = self.records.join(.leftOuter, accounts, on: accountId == aId).order(time.asc).order(aName.asc)
        } else if (sortBy == sorts.CATEGORY.rawValue) {
            condition = self.records.join(.leftOuter, categories, on: categoryId == cId).order(time.asc).order(cName.asc)
        }
        
        do {
            for record in try db!.prepare(condition) {
                records.append(Record(category: searchCategories(id: record[categoryId], alphabetical: false).name, amount: record[amount], account: searchAccounts(id: record[accountId], alphabetical: false).name, time: record[time])!)
            }
        } catch {
            print("Select failted")
        }
        return records
    }

    func addAccount(name: String) {
        do {
            let insert = accounts.insert(aName <- name)
            let _ = try db!.run(insert)

        } catch {
            print("Insert failed")
        }
    }

    func removeAccount(id: Int64) {
        var accountIds: [Int64] = []
        do {

            for categoryEntry in try db!.prepare(accounts.order(aName.asc)) {
                accountIds.append(categoryEntry[aId])
            }
            let delete = accounts.order(aName.asc).filter(aId == accountIds[Int(id)]).delete()
            try db!.run(delete)
        } catch {

        }
    }

    func updateAccount(id: Int64, newName: String) {
        do {
            let account = accounts.filter(aId == id)
            let update = account.update(aName <- newName)

            try db!.run(update)
        } catch {

        }
    }

    func addCategory(name: String) {
        do {
            let insert = categories.insert(cName <- name)
            let _ = try db!.run(insert)

        } catch {
            print("Insert failed")
        }
    }

    func removeCategory(id: Int64) {
        var categoryIds: [Int64] = []


        do {
            for categoryEntry in try db!.prepare(categories.order(cName.asc)) {
                categoryIds.append(categoryEntry[cId])
            }
            let delete = categories.filter(cId == categoryIds[Int(id)]).delete()
            try db!.run(delete)
        } catch {

        }
    }

    func updateCategory(id: Int64, newName: String) {
        do {
            let category = categories.filter(aId == id)
            let update = category.update(cName <- newName)

            try db!.run(update)
        } catch {

        }
    }

    func addRecord(catId: Int64, accId: Int64, amount: Double, timeInMilliseconds: Int64) {
        do {
            let insert = records.insert(accountId <- accId, categoryId <- catId, self.amount <- amount, time <- timeInMilliseconds, type <- 0)
            let _ = try db!.run(insert)

        } catch {

            print("Insert failed")
        }
    }

    func removeRecord(id: Int64) {
        var recordIds: [Int64] = []

        do {

            for recordEntry in try db!.prepare(records.order(time.asc)) {
                recordIds.append(recordEntry[rId])
            }
            let record = records.filter(rId == recordIds[Int(id)])
            let delete = record.delete()
            try db!.run(delete)
        } catch {

        }
    }

    func updateRecord(id: Int64, newCategoryId: Int64, newAccountId: Int64, newAmount: Double, newTime: Int64, newType: Int) {
        do {
            let record = records.filter(rId == id)
            let update = record.update(accountId <- newAccountId, categoryId <- newCategoryId, amount <- newAmount, time <- newTime, type <- newType)

            try db!.run(update)
        } catch {

        }
    }
    func searchAccounts(id: Int64, alphabetical: Bool) -> Account {
        var account: Account?
        var accountIds: [Int64] = []
        do {

            if (alphabetical == true) {
                for account in try db!.prepare(self.accounts.order(aName.asc)) {
                    accountIds.append(account.get(aId))
                }

                // DON'T HARDCODE IT
                for accountEntry in try db!.prepare(self.accounts.filter(aId == accountIds[Int(id)])) {
                    account = Account(id: accountEntry[aId], name: accountEntry[aName])

                }
            } else {
                for accountEntry in try db!.prepare(self.accounts.filter(aId == id)) {
                    account = Account(id: accountEntry.get(aId), name: accountEntry.get(aName))
                }
            }

        } catch {
            fatalError()
        }

        return account!
    }


    func searchCategories(id: Int64, alphabetical: Bool) -> Category {
        var category: Category?
        var categoryIds: [Int64] = []
        do {

            if (alphabetical == true) {
                for category in try db!.prepare(self.categories.order(cName.asc)) {
                    categoryIds.append(category.get(cId))
                }

                // DON'T HARDCODE IT
                for categoryEntry in try db!.prepare(self.categories.filter(cId == categoryIds[Int(id)])) {
                    category = Category(id: categoryEntry[cId], name: categoryEntry[cName])
                    
                }
            } else {
                for categoryEntry in try db!.prepare(self.categories.filter(cId == id)) {
                    category = Category(id: categoryEntry.get(cId), name: categoryEntry.get(cName))
                }
            }
        } catch {
            fatalError()
        }

        return category ?? Category(id: 0, name: "Category Not Specified")
    }

    func timeOrder(type: Int) -> [Record] {
        var records: [Record] = []
        var condition = self.records

        if (type == timeSorts.ASC.rawValue) {
            condition = self.records.order(time.asc)
        } else {
            condition = self.records.order(time.desc)
        }

        do {
            for record in try db!.prepare(condition) {
                records.append(Record(category: searchCategories(id: record[categoryId], alphabetical: false).name, amount: record[amount], account: searchAccounts(id: record[accountId], alphabetical: false).name, time: record[time])!)
            }
        } catch {

        }
        return records
    }
    
}
