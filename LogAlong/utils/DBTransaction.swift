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

    private func rdValues(_ row: Row) -> LTransaction? {
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

    func rdValuesJoinNone(_ row: Row) -> (id: Int64, rid: Int64, accountId: Int64, accountId2: Int64,
        amount: Double, type: TransactionType) {
            return (id: row[DBHelper.id],
                    rid: row[DBHelper.rid],
                    accountId: row[DBHelper.accountId],
                    accountId2: row[DBHelper.accountId2],
                    amount: row[DBHelper.amount],
                    type: TransactionType(rawValue: UInt8(row[DBHelper.type]))!)
    }

    func rdValuesJoinAccount(_ row: Row) -> (id: Int64, rid: Int64, accountId: Int64, accountId2: Int64,
        amount: Double, type: TransactionType, name: String) {
            return (id: row[table![DBHelper.id]],
                    rid: row[DBHelper.rid],
                    accountId: row[DBHelper.accountId],
                    accountId2: row[DBHelper.accountId2],
                    amount: row[DBHelper.amount],
                    type: TransactionType(rawValue: UInt8(row[table![DBHelper.type]]))!,
                    name: row[DBHelper.name] ?? "-")
    }

    func rdValuesJoinTag(_ row: Row) -> (id: Int64, rid: Int64, accountId: Int64, accountId2: Int64,
        amount: Double, type: TransactionType, tagId: Int64, name: String) {
            return (id: row[table![DBHelper.id]],
                    rid: row[DBHelper.rid],
                    accountId: row[DBHelper.accountId],
                    accountId2: row[DBHelper.accountId2],
                    amount: row[DBHelper.amount],
                    type: TransactionType(rawValue: UInt8(row[table![DBHelper.type]]))!,
                    tagId: row[DBHelper.tagId],
                    name: row[DBHelper.name] ?? "-")
    }

    func rdValuesJoinCategory(_ row: Row) -> (id: Int64, rid: Int64, accountId: Int64, accountId2: Int64,
        amount: Double, type: TransactionType, categoryId: Int64, name: String) {
            return (id: row[table![DBHelper.id]],
                    rid: row[DBHelper.rid],
                    accountId: row[DBHelper.accountId],
                    accountId2: row[DBHelper.accountId2],
                    amount: row[DBHelper.amount],
                    type: TransactionType(rawValue: UInt8(row[table![DBHelper.type]]))!,
                    categoryId: row[DBHelper.categoryId],
                    name: row[DBHelper.name] ?? "-")
    }

    func rdValuesJoinVendor(_ row: Row) -> (id: Int64, rid: Int64, accountId: Int64, accountId2: Int64,
        amount: Double, type: TransactionType, vendorId: Int64, name: String) {
            return (id: row[table![DBHelper.id]],
                    rid: row[DBHelper.rid],
                    accountId: row[DBHelper.accountId],
                    accountId2: row[DBHelper.accountId2],
                    amount: row[DBHelper.amount],
                    type: TransactionType(rawValue: UInt8(row[table![DBHelper.type]]))!,
                    vendorId: row[DBHelper.vendorId],
                    name: row[DBHelper.name] ?? "-")
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

        details.account.id = row[DBHelper.instance.accounts[DBHelper.id]]
        details.account.gid = row[DBHelper.instance.accounts[DBHelper.gid]]
        details.account.name = row[DBHelper.instance.accounts[DBHelper.name]]!

        if let name = row[DBHelper.instance.categories[DBHelper.name]] {
            details.category.name = name
            details.category.id = row[DBHelper.instance.categories[DBHelper.id]]
            details.category.gid = row[DBHelper.instance.categories[DBHelper.gid]]
        } else {
            details.category.name = ""
        }

        if let name = row[DBHelper.instance.tags[DBHelper.name]] {
            details.tag.name = name
            details.tag.id = row[DBHelper.instance.tags[DBHelper.id]]
            details.tag.gid = row[DBHelper.instance.tags[DBHelper.gid]]
        } else {
            details.tag.name = ""
        }

        if let name = row[DBHelper.instance.vendors[DBHelper.name]] {
            details.vendor.name = name
            details.vendor.id = row[DBHelper.instance.vendors[DBHelper.id]]
            details.vendor.gid = row[DBHelper.instance.vendors[DBHelper.gid]]
        } else {
            details.vendor.name = ""
        }

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

    func getTransfer(rid: Int64, copy: Bool) -> LTransaction? {
        do {
            if (copy) {
                for row in try DBHelper.instance.db!.prepare(table!
                    .filter(DBHelper.rid == rid && DBHelper.type == Int(TransactionType.TRANSFER_COPY.rawValue))) {
                        //TODO: error report if multiple entries found
                        return rdValues(row)
                }
            } else {
                for row in try DBHelper.instance.db!.prepare(table!
                    .filter(DBHelper.rid == rid && DBHelper.type == Int(TransactionType.TRANSFER.rawValue))) {
                        //TODO: error report if multiple entries found
                        return rdValues(row)
                }
            }
        } catch {
            LLog.e("\(self)", "unable to find row with rid: \(rid)")
        }
        return nil
    }

    func query(year: Int, month: Int, sort: Int, interval: Int, asc: Bool, search: LRecordSearch?) -> QueryType {
        var query = table!
        var order: Expressible?

        switch (sort) {
        case RecordsViewSortMode.ACCOUNT.rawValue:
            query = query.join(.leftOuter, DBHelper.instance.accounts, on: DBHelper.accountId == DBHelper.instance.accounts[DBHelper.id])
            order = DBHelper.instance.accounts[DBHelper.name].asc
        case RecordsViewSortMode.CATEGORY.rawValue:
            query = query.join(.leftOuter, DBHelper.instance.categories, on: DBHelper.categoryId == DBHelper.instance.categories[DBHelper.id])
            order = DBHelper.instance.categories[DBHelper.name].asc
        case RecordsViewSortMode.TAG.rawValue:
            query = query.join(.leftOuter, DBHelper.instance.tags, on: DBHelper.tagId == DBHelper.instance.tags[DBHelper.id])
            order = DBHelper.instance.tags[DBHelper.name].asc
        case RecordsViewSortMode.VENDOR.rawValue:
            query = query.join(.leftOuter, DBHelper.instance.vendors, on: DBHelper.vendorId == DBHelper.instance.vendors[DBHelper.id])
            order = DBHelper.instance.vendors[DBHelper.name].asc
        default: break
        }

        switch (interval) {
        case RecordsViewInterval.ALL_TIME.rawValue: break
        case RecordsViewInterval.ANNUALLY.rawValue:
            let startMs = Date(year: year, month: 0, day: 1).currentTimeMillis
            let endMs = Date(year: year + 1, month: 0, day: 1).currentTimeMillis
            query = query.filter(table![DBHelper.timestamp] >= startMs && table![DBHelper.timestamp] < endMs)

        default:
            let startMs = Date(year: year, month: month, day: 1).currentTimeMillis
            let (y, m) = LA.nextYM(year: year, month: month)
            let endMs = Date(year: y, month: m, day: 1).currentTimeMillis
            query = query.filter(table![DBHelper.timestamp] >= startMs && table![DBHelper.timestamp] < endMs)
        }

        if asc {
            if let ord = order {
                query = query.order(ord, table![DBHelper.timestamp].asc)
            } else {
                query = query.order(table![DBHelper.timestamp].asc)
            }
        } else {
            if let ord = order {
                query = query.order(ord, table![DBHelper.timestamp].desc)
            } else {
                query = query.order(table![DBHelper.timestamp].desc)
            }
        }

        return filter(by: search, with: query)
    }

    func filter(by: LRecordSearch?, with: QueryType?) -> QueryType {
        var query: QueryType

        if with != nil {
            query = with!
        } else {
            query = table!
        }

        if let search = by {
            if !search.all {
                if !search.accounts.isEmpty {
                    for acnt in search.accounts {
                        query = query.filter(table![DBHelper.accountId] == acnt
                            || table![DBHelper.accountId2] == acnt)
                    }
                }

                if !search.categories.isEmpty {
                    for cat in search.categories {
                        query = query.filter(table![DBHelper.categoryId] == cat)
                    }
                }

                if !search.vendors.isEmpty {
                    for ven in search.vendors {
                        query = query.filter(table![DBHelper.vendorId] == ven)
                    }
                }

                if !search.tags.isEmpty {
                    for tag in search.tags {
                        query = query.filter(table![DBHelper.tagId] == tag)
                    }
                }
            }

            if !search.allTime {
                if search.byEditTime {
                    query = query.filter(table![DBHelper.timestampAccess] >= search.from
                        && table![DBHelper.timestampAccess] <= search.to)
                } else {
                    query = query.filter(table![DBHelper.timestamp] >= search.from
                        && table![DBHelper.timestamp] <= search.to)
                }
            }

            if search.byValue {
                query = query.filter(table![DBHelper.amount] == search.value)
            }
        }

        return query
    }

    func getDetails(id: Int64) -> LTransactionDetails? {
        let query = table!.join(DBHelper.instance.accounts, on: DBHelper.accountId == DBHelper.instance.accounts[DBHelper.id])
            .join(.leftOuter, DBHelper.instance.categories, on: DBHelper.categoryId == DBHelper.instance.categories[DBHelper.id])
            .join(.leftOuter, DBHelper.instance.tags, on: DBHelper.tagId == DBHelper.instance.tags[DBHelper.id])
            .join(.leftOuter, DBHelper.instance.vendors, on: DBHelper.vendorId == DBHelper.instance.vendors[DBHelper.id])
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
