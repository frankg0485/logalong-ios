//
//  RecordDB.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import SQLite

class RecordDB {
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

            for account in try db!.prepare(self.accounts) {
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

            for category in try db!.prepare(self.categories) {
                categories.append(category[cName])
            }
        } catch {
            print("Select failed")
        }
        return categories
    }

    func getRecords() -> [Record] {
        var records: [Record] = []

        do {
            for record in try db!.prepare(self.records) {
                records.append(Record(category: searchCategories(id: record[categoryId]), amount: record[amount], account: searchAccounts(id: record[accountId]))!)
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


    func addCategory(name: String) {
        do {
            let insert = categories.insert(cName <- name)
            let _ = try db!.run(insert)

        } catch {
            print("Insert failed")
        }
    }

    func addRecord(catId: Int64, accId: Int64, amount: Double) {
        do {
            let insert = records.insert(accountId <- accId, categoryId <- catId, self.amount <- amount, time <- 0, type <- 0)
            let _ = try db!.run(insert)

        } catch {
            
            print("Insert failed")
        }
    }

    func searchAccounts(id: Int64) -> String {
        var account = ""
        do {
            for accountEntry in try db!.prepare(self.accounts.filter(aId == id)) {
                account = accountEntry.get(aName)
            }

        } catch {
            fatalError()
        }
        
        return account
    }

    func searchAccountId(name: String) -> Int64 {
        var id: Int64 = 0
        do {
            for account in try db!.prepare(self.accounts.filter(aName == name)) {
                
                id = account.get(aId)
            }
        } catch {
            fatalError()
        }
        return id
    }

    func searchCategories(id: Int64) -> String {
        var category = ""
        do {
            for categoryEntry in try db!.prepare(self.categories.filter(cId == id)) {
                category = categoryEntry.get(cName)
            }

        } catch {
            fatalError()
        }

        return category
    }

    func searchCategoryId(name: String) -> Int64 {
        var id: Int64 = 0
        do {
            for category in try db!.prepare(self.categories.filter(cName == name)) {

                id = category.get(cId)
            }
        } catch {
            fatalError()
        }
        return id
    }

}
