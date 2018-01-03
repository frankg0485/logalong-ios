//  transDB.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBTransaction: DBGeneric<LTransaction> {
    static let instance = DBTransaction()

    override init() {
        super.init()
        table = DBHelper.instance.transactions
        getValues = rdValues
        setValues = wrValues
    }
/*
    enum sorts: Int {
        case ACCOUNT = 1
        case CATEGORY = 2
    }

    enum timeSorts: Int {
        case ASC = 1
        case DESC = 2
    }
*/
    func rdValues(_ row: Row) -> LTransaction? {
        return LTransaction(id: row[DBHelper.id],
                            gid: row[DBHelper.gid],
                            rid: row[DBHelper.rid],
                            accountId: row[DBHelper.accountId],
                            accountId2: row[DBHelper.accountId2],
                            amount: row[DBHelper.amount],
                            type: TransactionType(rawValue: UInt8(row[DBHelper.type]))!,
                            categoryId: row[DBHelper.categoryId],
                            tagId: row[DBHelper.tagId],
                            vendorId: row[DBHelper.vendorId],
                            note: row[DBHelper.note],
                            by: row[DBHelper.by],
                            timestamp: row[DBHelper.timestamp],
                            create: row[DBHelper.timestampCretae],
                            access: row[DBHelper.timestampAccess])
    }

    private func wrValues(_ value: LTransaction) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.rid <- value.rid,
                DBHelper.accountId <- value.accountId,
                DBHelper.accountId2 <- value.accountId2,
                DBHelper.amount <- value.amount,
                DBHelper.type <- Int(value.type.rawValue),
                DBHelper.categoryId <- value.categoryId,
                DBHelper.tagId <- value.tagId,
                DBHelper.vendorId <- value.vendorId,
                DBHelper.note <- value.note,
                DBHelper.by <- value.by,
                DBHelper.timestamp <- value.timestamp,
                DBHelper.timestampCretae <- value.timestampCreate,
                DBHelper.timestampAccess <- value.timestampAccess]
    }

    func rdDetails(_ row: Row) -> LTransactionDetails? {
        let details = LTransactionDetails()
        details.id = row[DBHelper.instance.transactions[DBHelper.id]]
        details.gid = row[DBHelper.instance.transactions[DBHelper.gid]]
        details.rid = row[DBHelper.instance.transactions[DBHelper.rid]]
        details.accountId = row[DBHelper.accountId]
        details.accountId2 = row[DBHelper.accountId2]
        details.categoryId = row[DBHelper.categoryId]
        details.tagId = row[DBHelper.tagId]
        details.vendorId = row[DBHelper.vendorId]
        details.amount = row[DBHelper.amount]
        details.timestamp = row[DBHelper.timestamp]
        details.note = row[DBHelper.note]
        details.by = row[DBHelper.by]
        details.type = TransactionType(rawValue: UInt8(row[DBHelper.instance.transactions[DBHelper.type]]))!
        details.timestampCreate = row[DBHelper.instance.transactions[DBHelper.timestampCretae]]
        details.timestampAccess = row[DBHelper.instance.transactions[DBHelper.timestampAccess]]

        details.account.name = row[DBHelper.instance.accounts[DBHelper.name]]
        details.category.name = row[DBHelper.instance.categories[DBHelper.name]]
        details.tag.name = row[DBHelper.instance.tags[DBHelper.name]]
        details.vendor.name = row[DBHelper.instance.vendors[DBHelper.name]]

        return details
    }

    func getAll() -> [LTransaction] {
        return super.getAll(by: DBHelper.timestamp.asc)
    }

    func getAllBy(id: Int64, col: Expression<Int64>) -> [LTransaction] {
        var transactions: [LTransaction] = []

        do {
            for row in try DBHelper.instance.db!.prepare(table!.filter(col == id)
                .order(DBHelper.timestamp.asc)) {
                    transactions.append(rdValues(row)!)
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

    func detailsQuery() -> QueryType {
        let query = table!.join(DBHelper.instance.accounts, on: DBHelper.accountId == DBHelper.instance.accounts[DBHelper.id])
            .join(DBHelper.instance.categories, on: DBHelper.categoryId == DBHelper.instance.categories[DBHelper.id])
            .join(DBHelper.instance.tags, on: DBHelper.tagId == DBHelper.instance.tags[DBHelper.id])
            .join(DBHelper.instance.vendors, on: DBHelper.vendorId == DBHelper.instance.vendors[DBHelper.id])

        return table!
    }

    func getDetails(id: Int64) -> LTransactionDetails? {
        let query = table!.join(DBHelper.instance.accounts, on: DBHelper.accountId == DBHelper.instance.accounts[DBHelper.id])
            .join(DBHelper.instance.categories, on: DBHelper.categoryId == DBHelper.instance.categories[DBHelper.id])
            .join(DBHelper.instance.tags, on: DBHelper.tagId == DBHelper.instance.tags[DBHelper.id])
            .join(DBHelper.instance.vendors, on: DBHelper.vendorId == DBHelper.instance.vendors[DBHelper.id])
            .filter(DBHelper.instance.transactions[DBHelper.id] == id)

        do {
            for row in try DBHelper.instance.db!.prepare(query) {
                //TODO: error report if multiple entries found
                return rdDetails(row)
            }
        } catch {
            LLog.e("\(self)", "unable to find row with id: \(id)")
        }

        return nil
    }

    func updateTransferCopyRid(transaction: LTransaction) -> Bool {
        var ret = false;
        if (TransactionType.TRANSFER == transaction.type) {
            return false
        }

        var cv = [SQLite.Setter]()
        cv.append(DBHelper.rid <- transaction.rid)

        do {
            let query = table!.filter(DBHelper.accountId == transaction.accountId2
                && DBHelper.accountId2 == transaction.accountId
                && DBHelper.amount == transaction.amount
                && DBHelper.timestamp == transaction.timestamp)
                .update(cv)

            try DBHelper.instance.db!.run(query)
            ret = true
        } catch {
            LLog.e("\(self)", "DB transfer copy update failed")
        }

        return ret
    }
}
