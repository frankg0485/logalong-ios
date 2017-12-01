//  transDB.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBTransaction: DBGeneric {
    static let instance = DBTransaction()
    let table = DBHelper.instance.transactions

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
        return [DBHelper.categoryId <- value.categoryId,
                DBHelper.accountId <- value.accountId,
                DBHelper.amount <- value.amount,
                DBHelper.type <- value.type,
                DBHelper.timestamp <- value.timestamp]
    }

    func getAll() -> [LTransaction] {
        var transactions: [LTransaction] = []

        do {
            for row in try DBHelper.instance.db!.prepare(table.order(DBHelper.timestamp.asc)) {
                transactions.append(getValues(row)!)
            }
        } catch {
            LLog.e("\(self)", "Get all transactions failed")
        }

        return transactions
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

    func add(_ transaction: inout LTransaction) -> Bool {
        return super.add(DBHelper.instance.transactions, dbase: &transaction,
                         categoryId: transaction.categoryId,
                         accountId: transaction.accountId,
                         amount: transaction.amount,
                         timestamp: transaction.timestamp,
                         type: transaction.type)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(DBHelper.instance.transactions, id: id)
    }

    func update(_ transaction: LTransaction) -> Bool {
        return super.update(DBHelper.instance.transactions,
                            id: transaction.id,
                            accountId: transaction.accountId,
                            categoryId: transaction.categoryId,
                            amount: transaction.amount,
                            timestamp: transaction.timestamp,
                            type: transaction.type)
    }
}
