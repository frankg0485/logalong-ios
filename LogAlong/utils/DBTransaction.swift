//  transDB.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBTransaction: DBGeneric {
    static let instance = DBTransaction()
    private let table = DBHelper.instance.transactions

    enum sorts: Int {
        case ACCOUNT = 1
        case CATEGORY = 2
    }

    enum timeSorts: Int {
        case ASC = 1
        case DESC = 2
    }

    private func getValues(_ row: Row) -> LTransaction? {
        return LTransaction(categoryId: row[DBHelper.categoryId],
                            amount: row[DBHelper.amount],
                            accountId: row[DBHelper.accountId],
                            timestamp: row[DBHelper.timestamp],
                            rowId: row[DBHelper.id])!
    }

    private func setValues(_ value: LTransaction) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.categoryId <- value.categoryId,
                DBHelper.accountId <- value.accountId,
                DBHelper.amount <- value.amount,
                DBHelper.type <- value.type,
                DBHelper.timestamp <- value.timestamp]
    }

    func getAll() -> [LTransaction] {
        return super.getAll(table, getValues, by: DBHelper.timestamp.asc)
    }

    func get(id: Int64) -> LTransaction? {
        return super.get(table, getValues, id: id)
    }

    func get(gid: Int64) -> LTransaction? {
        return super.get(table, getValues, gid: gid)
    }

    func add(_ account: inout LTransaction) -> Bool {
        return super.add(table, setValues, &account)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(table, id: id)
    }

    func update(_ trans: LTransaction) -> Bool {
        return super.update(table, setValues, trans)
    }

    func getAll(sortBy: Int, timeAsc: Bool) -> [LTransaction] {
        return getAll()

        /* TODO: the following join helps with the 'sort', but they don't actually belong here
         var transactions: [LTransaction] = []

         var condition = table.join(.leftOuter, DBHelper.instance.accounts,
         on: DBHelper.accountId == DBHelper.instance.accounts[DBHelper.id])
         .join(.leftOuter, DBHelper.instance.categories,
         on: DBHelper.categoryId == DBHelper.instance.categories[DBHelper.id])

         if (timeAsc == true) {
         condition = condition.order(DBHelper.timestamp.asc)
         }
         if (timeAsc == false) {
         condition = condition.order(DBHelper.timestamp.desc)
         }

         if (sortBy == sorts.ACCOUNT.rawValue) {
         if (timeAsc == true) {
         condition = condition.order(DBHelper.instance.accounts[DBHelper.name].asc,
         table[DBHelper.timestamp].asc)
         } else {
         condition = condition.order(DBHelper.instance.accounts[DBHelper.name].asc,
         table[DBHelper.timestamp].desc)
         }
         } else if (sortBy == sorts.CATEGORY.rawValue) {
         if (timeAsc == true) {
         condition = condition.order(DBHelper.instance.categories[DBHelper.name].asc,
         table[DBHelper.timestamp].asc)
         } else {
         condition = condition.order(DBHelper.instance.categories[DBHelper.name].asc,
         table[DBHelper.timestamp].desc)
         }
         }

         do {
         for row in try DBHelper.instance.db!.prepare(condition) {
         transactions.append(getValues(row)!)
         }
         } catch {
         LLog.e("\(self)", "Select failed")
         }

         return transactions
         */
    }

    func getAllBy(id: Int64, col: Expression<Int64>) -> [LTransaction] {
        var transactions: [LTransaction] = []

        do {
            for row in try DBHelper.instance.db!.prepare(table.filter(col == id)
                .order(DBHelper.timestamp.asc)) {
                    transactions.append(getValues(row)!)
            }
        } catch {
            LLog.e("\(self)", "Search failed")
        }

        return transactions
    }

    func getAllByAccount(accountId: Int64) -> [LTransaction] {
        return getAllBy(id: accountId, col: DBHelper.accountId)
    }

    func getAllByCategory(categoryId: Int64) -> [LTransaction] {
        return getAllBy(id: categoryId, col: DBHelper.categoryId)
    }
}
