//
//  DBLoader.swift
//  LogAlong
//
//  Created by Michael Gao on 12/30/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LSection {
    var show: Bool
    var rows: Int
    var txt: String
    var balance: Double
    var income: Double
    var expense: Double
    var ids = [Int64]()

    init(show: Bool = true, rows: Int = 1, txt: String = "", balance: Double = 0, income: Double = 0, expense: Double = 0) {
        self.show = show
        self.rows = rows
        self.txt = txt
        self.balance = balance
        self.income = income
        self.expense = expense
    }
}

class Records {
    var startIndex: Int = 0
    var endIndex: Int = 0
    var entries = [LTransaction]()
    var sections: [LSection] = [LSection]()
}

class DBLoader {
    private let table = DBHelper.instance.transactions
    private var records: Records = Records()

    var year: Int = 0
    var month: Int = 0
    var sort: Int = 0
    var interval: Int = 0
    var asc = true
    var search: LRecordSearch?

    init(year: Int, month: Int, sort: Int, interval: Int, asc: Bool, search: LRecordSearch) {
        self.year = year
        self.month = month
        self.sort = sort
        self.interval = interval
        self.asc = asc
        self.search = search

        reset()
    }

    init(search: LRecordSearch) {
        self.search = search
    }

    func getStartEndTime() -> (startMs: Int64, endMs: Int64) {
        let queryStart = table.select(DBHelper.timestamp).order(DBHelper.timestamp.asc).limit(1)
        let queryEnd = table.select(DBHelper.timestamp).order(DBHelper.timestamp.desc).limit(1)
        var start: Int64 = 0
        var end: Int64 = 0

        do {
            for row in try DBHelper.instance.db!.prepare(queryStart) {
                start = row[DBHelper.timestamp]
            }

            for row in try DBHelper.instance.db!.prepare(queryEnd) {
                end = row[DBHelper.timestamp]
            }
        } catch {
            LLog.e("\(self)", "unable to find valid row")
        }

        return (start, end)
    }

    func getSectionCount() -> Int {
        return records.sections.count
    }

    func getSection(_ at: Int) -> LSection {
        return records.sections[at]
    }

    func getRecord(section: Int, row: Int) -> LTransaction {
        return DBTransaction.instance.get(id: records.sections[section].ids[row])!
    }

    func reset() {
        records.entries.removeAll()
        records.sections.removeAll()
        var prevId: Int64 = -1
        var prevTransferRid: Int64 = -1
        var newSection = true
        var skip = false
        var section: LSection?

        let query = DBTransaction.instance.query(year: year, month: month, sort: sort, interval: interval, asc: asc, search: search)
        do {
            var id: Int64 = 0
            var rid: Int64 = 0
            var accountId: Int64 = 0
            var accountId2: Int64 = 0
            var categoryId: Int64 = 0
            var tagId: Int64 = 0
            var vendorId: Int64 = 0
            var amount: Double
            var type: TransactionType
            var name = ""

            for row in try DBHelper.instance.db!.prepare(query) {
                switch (sort) {
                case RecordsViewSortMode.ACCOUNT.rawValue:
                    (id, rid, accountId, accountId2, amount, type, name) = DBTransaction.instance.rdValuesJoinAccount(row)
                    newSection = (prevId == -1 || prevId != accountId)
                    prevId = accountId
                case RecordsViewSortMode.CATEGORY.rawValue:
                    (id, rid, accountId, accountId2, amount, type, categoryId, name) = DBTransaction.instance.rdValuesJoinCategory(row)
                    newSection = (prevId == -1 || prevId != categoryId)
                    prevId = categoryId
                case RecordsViewSortMode.TAG.rawValue:
                    (id, rid, accountId, accountId2, amount, type, tagId, name) = DBTransaction.instance.rdValuesJoinTag(row)
                    newSection = (prevId == -1 || prevId != tagId)
                    prevId = tagId
                case RecordsViewSortMode.VENDOR.rawValue:
                    (id, rid, accountId, accountId2, amount, type, vendorId, name) = DBTransaction.instance.rdValuesJoinVendor(row)
                    newSection = (prevId == -1 || prevId != vendorId)
                    prevId = vendorId
                default:
                    (id, rid, accountId, accountId2, amount, type) = DBTransaction.instance.rdValuesJoinNone(row)
                }

                if (newSection) {
                    section = LSection(show: true, rows: 1)
                    section!.txt = name

                    records.sections.append(section!)
                    newSection = false
                } else {
                    if ((type == TransactionType.TRANSFER || type == TransactionType.TRANSFER_COPY) && (prevTransferRid == rid)) {
                        skip = true
                    } else {
                        section!.rows += 1
                        skip = false
                    }
                }
                prevTransferRid = (type == TransactionType.TRANSFER || type == TransactionType.TRANSFER_COPY) ? rid : -1

                if (!skip) {
                    section!.ids.append(id)
                    if (type == TransactionType.INCOME || type == TransactionType.TRANSFER_COPY) {
                        section!.balance += amount
                        section!.income += amount
                    } else {
                        section!.balance -= amount
                        section!.expense += amount
                    }
                }
            }
        } catch {
            LLog.w("\(self)", "data not available")
        }

        if var sect = section {
            if (sort == RecordsViewSortMode.TIME.rawValue) {
                sect.show = false
            }
        }
    }
}
