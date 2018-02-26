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
    var id: Int64 = 0

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
    //var startIndex: Int = 0
    //var endIndex: Int = 0
    //var entries = [LTransaction]()
    var internalTransferAmount: Double = 0
    var sections: [LSection] = [LSection]()

    // entries are only valid when browsing in 'anually' mode
    var annualExpenses = [Double]()
    var annualIncomes = [Double]()
}

class DBLoader {
    //private let table = DBHelper.instance.transactions
    var records: Records = Records()

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
        let query = DBTransaction.instance.filter(by: search, with: nil)
        let queryStart = query.order(DBHelper.timestamp.asc).limit(1)
        let queryEnd = query.order(DBHelper.timestamp.desc).limit(1)
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

    func getInternalTransferAmount() -> Double {
        return records.internalTransferAmount
    }

    func reset() {
        //records.entries.removeAll()
        records.sections.removeAll()
        records.annualExpenses = [Double](repeating: 0, count: 12)
        records.annualIncomes = [Double](repeating: 0, count: 12)

        var prevId: Int64 = -1
        var prevTransferRid: Int64 = -1
        var newSection = true
        var skip = false
        var section: LSection?
        var searchAccountIds = [Int64]()
        if let ss = search {
            if !ss.all && !ss.accounts.isEmpty {
                searchAccountIds = ss.accounts
            }
        }

        records.internalTransferAmount = 0
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
            var timestamp: Int64 = 0
            var name = ""

            for row in try DBHelper.instance.db!.prepare(query) {
                switch (sort) {
                case RecordsViewSortMode.ACCOUNT.rawValue:
                    (id, rid, accountId, accountId2, amount, type, timestamp, name) = DBTransaction.instance.rdValuesJoinAccount(row)
                    newSection = (prevId == -1 || prevId != accountId)
                    prevId = accountId

                    //exclude accounts if account filter is present
                    if !searchAccountIds.isEmpty && !searchAccountIds.contains(accountId) {
                        continue
                    }
                case RecordsViewSortMode.CATEGORY.rawValue:
                    (id, rid, accountId, accountId2, amount, type, categoryId, timestamp, name) = DBTransaction.instance.rdValuesJoinCategory(row)
                    newSection = (prevId == -1 || prevId != categoryId)
                    prevId = categoryId
                case RecordsViewSortMode.TAG.rawValue:
                    (id, rid, accountId, accountId2, amount, type, tagId, timestamp, name) = DBTransaction.instance.rdValuesJoinTag(row)
                    newSection = (prevId == -1 || prevId != tagId)
                    prevId = tagId
                case RecordsViewSortMode.VENDOR.rawValue:
                    (id, rid, accountId, accountId2, amount, type, vendorId, timestamp, name) = DBTransaction.instance.rdValuesJoinVendor(row)
                    newSection = (prevId == -1 || prevId != vendorId)
                    prevId = vendorId
                default:
                    (id, rid, accountId, accountId2, amount, type, timestamp) = DBTransaction.instance.rdValuesJoinNone(row)
                }

                skip = false
                if (newSection) {
                    section = LSection(show: true, rows: 1)
                    section!.txt = name
                    section!.id = prevId

                    newSection = false
                    records.sections.append(section!)
                } else {
                    if ((type == TransactionType.TRANSFER || type == TransactionType.TRANSFER_COPY) && (prevTransferRid == rid)) {
                        skip = true
                    } else {
                        section!.rows += 1
                    }
                }
                prevTransferRid = (type == TransactionType.TRANSFER || type == TransactionType.TRANSFER_COPY) ? rid : -1

                if (!skip) {
                    section!.ids.append(id)

                    // transfer is counted to income/expense/balance only upon one of the following
                    // - either 'from' or 'to' is missing from currently selected accounts
                    // - view is sorted by account
                    if (type == TransactionType.TRANSFER || type == TransactionType.TRANSFER_COPY) {
                        if sort == RecordsViewSortMode.ACCOUNT.rawValue {
                            // when sorting by account, whether transfer is counted as income or expense
                            // depends on what account section refers to.
                            if (section!.id == accountId && type == TransactionType.TRANSFER) ||
                                (section!.id == accountId2 && type == TransactionType.TRANSFER_COPY) {
                                section!.balance -= amount
                                section!.expense += amount
                            } else {
                                section!.balance += amount
                                section!.income += amount
                            }

                            // track internal transfer amount, only when sorting in account. This internal amount is
                            // then used to adjust the global header area income/expense column, which is otherwise
                            // a simple sum-up of section income/expense
                            if searchAccountIds.isEmpty || searchAccountIds.contains(accountId) && searchAccountIds.contains(accountId2) {
                                records.internalTransferAmount += amount
                            }
                        } else if !searchAccountIds.isEmpty {
                            if !searchAccountIds.contains(accountId) {
                                if (type == TransactionType.TRANSFER) {
                                    section!.balance += amount
                                    section!.income += amount
                                } else {
                                    section!.balance -= amount
                                    section!.expense += amount
                                }
                            } else if !searchAccountIds.contains(accountId2) {
                                if (type == TransactionType.TRANSFER_COPY) {
                                    section!.balance += amount
                                    section!.income += amount
                                } else {
                                    section!.balance -= amount
                                    section!.expense += amount
                                }
                            }
                        }
                    } else {
                        if (type == TransactionType.INCOME) {
                            section!.balance += amount
                            section!.income += amount
                        } else {
                            section!.balance -= amount
                            section!.expense += amount
                        }
                    }
                }

                if interval == RecordsViewInterval.ANNUALLY.rawValue {
                    let (_, m, _) = LA.ymd(milliseconds: timestamp)
                    if type == .INCOME || type == .TRANSFER_COPY {
                        records.annualIncomes[m] += amount
                    } else {
                        records.annualExpenses[m] += amount
                    }

                    if skip {
                        records.annualIncomes[m] -= amount
                        records.annualExpenses[m] -= amount
                    }
                }
            }
        } catch {
            LLog.w("\(self)", "data not available")
        }

        if let sect = section {
            if (sort == RecordsViewSortMode.TIME.rawValue) {
                sect.show = false
            }
        }
    }
}
