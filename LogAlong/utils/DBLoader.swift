//
//  DBLoader.swift
//  LogAlong
//
//  Created by Michael Gao on 12/30/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

struct LSection {
    var show: Bool
    var rows: Int
    var txt: String?
    var balance: Double?
    var income: Double?
    var expense: Double?

    init(show: Bool, rows: Int, txt: String? = nil, balance: Double? = nil, income: Double? = nil, expense: Double? = nil) {
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
    //var entries: [LTransactionDetails] = [LTransactionDetails]()
    var entries = [LTransaction]()
    var sections: [LSection] = [LSection]()
}

class DBLoader {
    private let table = DBHelper.instance.transactions
    private var records: Records = Records()

    init(year: Int, month: Int, sort: Int, interval: Int, search: LRecordSearch) {
        reset()
    }

    init(search: LRecordSearch) {

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
        return records.entries[row]
    }

    func reset() {
        records.entries.removeAll()
        records.sections.removeAll()

        let query = DBTransaction.instance.detailsQuery()
        do {
            for row in try DBHelper.instance.db!.prepare(query) {
                //TODO: error report if multiple entries found
                records.entries.append(DBTransaction.instance.rdValues(row)!)
            }
        } catch {
            LLog.w("\(self)", "data not available")
        }

        if (records.entries.count > 0) {
            let sect: LSection = LSection(show: false, rows: records.entries.count)
            records.sections.append(sect)
        }
    }
}
