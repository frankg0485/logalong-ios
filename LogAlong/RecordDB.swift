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






}
