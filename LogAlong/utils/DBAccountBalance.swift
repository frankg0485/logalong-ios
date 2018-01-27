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

    private static var cancel = false
    static func rescallCancel() {
        cancel = true
    }
    static func rescan() {
        cancel = false

        let acnts = DBAccount.instance.getAll()
        var accounts: Set<Int64> = Set<Int64>()
        for a in acnts {
            accounts.insert(a.id)
        }

        if (accounts.count == 0) {
            LLog.d("\(self)", "no account left, deleting all balances");
            DBAccountBalance.instance.removeAll() //clean up balances if all accounts are removed.
            return
        }

        var doubles = [Double](repeating: 0, count: 12)
        var lastAccountId: Int64 = 0
        var lastYear: Int = 0

        do {
            for row in try DBHelper.instance.db!.prepare(DBTransaction.instance.table!.order(DBHelper.accountId.asc)) {
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
                } else if (lastAccountId != accountId || lastYear != year) {
                    addUpdateAccountBalance(doubles, lastAccountId, lastYear)

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
            addUpdateAccountBalance(doubles, lastAccountId, lastYear)
        }

        for a in accounts {
            _ = DBAccountBalance.instance.remove(accountId: a)
        }
    }
}


/*
 public static void getAccountSummaryForCurrentCursor(LAccountSummary summary, Cursor cursor, long[] accountIds) {
 double income = 0;
 double expense = 0;

 if (cursor != null && cursor.getCount() > 0) {
 cursor.moveToFirst();
 do {
 double value = cursor.getDouble(cursor.getColumnIndexOrThrow(DBHelper.TABLE_COLUMN_AMOUNT));
 long account1 = cursor.getLong(cursor.getColumnIndexOrThrow(DBHelper.TABLE_COLUMN_ACCOUNT));
 long account2 = cursor.getLong(cursor.getColumnIndexOrThrow(DBHelper.TABLE_COLUMN_ACCOUNT2));
 int type = cursor.getInt(cursor.getColumnIndexOrThrow(DBHelper.TABLE_COLUMN_TYPE));
 if (type == LTransaction.TRANSACTION_TYPE_INCOME) income += value;
 else if (type == LTransaction.TRANSACTION_TYPE_EXPENSE) expense += value;
 int considerTransfer = 2;
 if (null != accountIds) {
 for (int ii = 0; ii < accountIds.length; ii++) {
 if (accountIds[ii] == account1 || accountIds[ii] == account2) {
 considerTransfer++;
 }
 }
 }

 if (considerTransfer != 2) {
 if (type == LTransaction.TRANSACTION_TYPE_TRANSFER) {
 expense += value;
 } else if (type == LTransaction.TRANSACTION_TYPE_TRANSFER_COPY) {
 income += value;
 }
 }
 } while (cursor.moveToNext());
 }
 summary.setBalance(income - expense);
 summary.setIncome(income);
 summary.setExpense(expense);
 }
 }
*/
