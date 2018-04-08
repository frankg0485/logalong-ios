//
//  DBAccountBalance.swift
//  LogAlong
//
//  Created by Michael Gao on 1/26/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//
import SQLite

class DBAccountBalance : DBGeneric<LAccountYearBalance> {
    static let instance = DBAccountBalance()

    override init() {
        super.init()
        table = DBHelper.instance.accountBalances
        getValues = rdValues
        setValues = wrValues
    }

    private func rdValues(_ row: Row) -> LAccountYearBalance? {
        return LAccountYearBalance(id: row[DBHelper.id],
                               accountId: row[DBHelper.accountId],
                               year: row[DBHelper.year],
                               balance: row[DBHelper.balance])
    }

    private func wrValues(_ value: LAccountYearBalance) -> [SQLite.Setter] {
        return [DBHelper.accountId <- value.accountId,
                DBHelper.year <- value.year,
                DBHelper.balance <- value.balance]
    }

    func getAll() -> [LAccountYearBalance] {
        return super.getAll(by: DBHelper.year.asc)
    }

    func get(accountId: Int64, year: Int) -> LAccountYearBalance? {
        do {
            for row in try DBHelper.instance.db!.prepare(table!.filter(DBHelper.accountId == accountId
                && DBHelper.year == year)) {
                    //TODO: error report if multiple entries found
                    return rdValues(row)
            }
        } catch {
            LLog.e("\(self)", "unable to find row with accountId: \(accountId)")
        }
        return nil
    }

    func get(accountId: Int64) -> [LAccountYearBalance]? {
        var yb = [LAccountYearBalance]()
        do {
            for row in try DBHelper.instance.db!.prepare(table!.filter(DBHelper.accountId == accountId)) {
                if let b = rdValues(row) {
                    yb.append(b)
                }
            }
        } catch {
            LLog.e("\(self)", "unable to find row with accountId: \(accountId)")
        }
        return yb.isEmpty ? nil : yb
    }

    func remove(accountId: Int64) -> Bool {
        var ret = false

        do {
            let delete = table!.filter(DBHelper.accountId == accountId).delete()
            try DBHelper.instance.db!.run(delete)
            ret = true
        } catch {
            LLog.e("\(self)", "DB deletion failed")
        }
        return ret
    }

    func removeAll() {
        do {
            try DBHelper.instance.db!.run(table!.delete())
        } catch {
            LLog.e("\(self)", "DB delete all failed")
        }
    }

    private static func addUpdateAccountBalance(_ doubles: [Double], _ accountId: Int64, _ year: Int) {
        var newEntry = false
        var balance = DBAccountBalance.instance.get(accountId: accountId, year: year)
        if (balance == nil) {
            balance = LAccountYearBalance(id: 0, accountId: accountId, year: year, balance: "")
            newEntry = true;
        }
        balance!.setBalanceValues(doubles)
        if (newEntry) {
            _ = DBAccountBalance.instance.add(&balance!)
        } else {
            _ = DBAccountBalance.instance.update(balance!)
        }
    }

    static func updateAccountBalance(id: Int64, amount: Double, timestamp: Int64) {
        let (year, month, _) = LA.ymd(milliseconds: timestamp)
        var doubles = [Double](repeating: 0, count: 12)
        if let ayb = DBAccountBalance.instance.get(accountId: id, year: year) {
            doubles = ayb.getBalanceValues()
        }
        doubles[month] += amount
        addUpdateAccountBalance(doubles, id, year)
    }

    private static var cancel = false
    static func rescanCancel() {
        cancel = true
    }
    static func rescan(reset: Bool = true) {
        if Thread.isMainThread {
            LLog.w("\(self)", "API is not supposed to be called from mainthread");
            return
        }

        cancel = false

        let acnts = DBAccount.instance.getAll()
        var accounts: Set<Int64> = Set<Int64>()
        for a in acnts {
            accounts.insert(a.id)
        }

        if (accounts.count == 0) {
            LLog.d("\(self)", "no account left, deleting all balances");
            DispatchQueue.main.sync {
                DBAccountBalance.instance.removeAll() //clean up balances if all accounts are removed.
            }
            return
        }

        var doubles = [Double](repeating: 0, count: 12)
        var lastAccountId: Int64 = 0
        var lastYear: Int = 0

        do {
            for row in try DBHelper.instance.db!.prepare(DBTransaction.instance.table!.order(DBHelper.accountId.asc, DBHelper.timestamp.asc)) {
                if cancel {
                    return
                }

                let accountId = row[DBHelper.accountId]
                if accountId == 0 {
                    LLog.w("\(self)", "unexpected invalid account id")
                    continue
                }
                accounts.remove(accountId)

                let amount = row[DBHelper.amount]
                let type = TransactionType(rawValue: UInt8(row[DBHelper.type]))!
                let (year, month, _) = LA.ymd(milliseconds: row[DBHelper.timestamp])

                if (lastAccountId == 0) {
                    lastAccountId = accountId
                    lastYear = year
                    DispatchQueue.main.sync {
                        if reset { _ = DBAccountBalance.instance.remove(accountId: accountId) }
                    }
                } else if (lastAccountId != accountId || lastYear != year) {
                    if lastAccountId != accountId {
                        DispatchQueue.main.sync {
                            if reset { _ = DBAccountBalance.instance.remove(accountId: accountId) }
                        }
                    }

                    DispatchQueue.main.sync {
                        addUpdateAccountBalance(doubles, lastAccountId, lastYear)
                    }

                    lastAccountId = accountId
                    lastYear = year
                    for ii in 0..<12 {
                        doubles[ii] = 0.0
                    }
                }
                doubles[month] += (type == .INCOME || type == .TRANSFER_COPY) ? amount : -amount;
            }
        } catch {
            LLog.e("\(self)", "unable to find row")
        }

        if (lastYear != 0) {
            DispatchQueue.main.sync {
                addUpdateAccountBalance(doubles, lastAccountId, lastYear)
            }
        }

        DispatchQueue.main.sync {
            for a in accounts {
                _ = DBAccountBalance.instance.remove(accountId: a)
            }
        }
        LLog.d("\(self)", "rescan completed")
    }
}
