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
