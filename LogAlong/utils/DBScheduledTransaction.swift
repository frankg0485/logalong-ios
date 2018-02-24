//
//  DBScheduledTransaction.swift
//  LogAlong
//
//  Created by Michael Gao on 2/22/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//
import SQLite

class DBScheduledTransaction: DBGeneric<LScheduledTransaction> {
    static let instance = DBScheduledTransaction()

    override init() {
        super.init()
        table = DBHelper.instance.scheduledTransactions
        getValues = rdValues
        setValues = wrValues
    }

    private func rdValues(_ row: Row) -> LScheduledTransaction? {
        return LScheduledTransaction(scheduleTime: row[DBHelper.scheduleTime],
                                     repeatCount: row[DBHelper.repeatCount],
                                     repeatUnit: row[DBHelper.repeatUnit],
                                     repeatInterval: row[DBHelper.repeatInterval],
                                     enabled: row[DBHelper.enable] != 0,
                                     trans: DBTransaction.parseRow(row))
    }

    private func wrValues(_ value: LScheduledTransaction) -> [SQLite.Setter] {
        var setter = DBTransaction.composeRow(value)
        setter.append(contentsOf: [
            DBHelper.scheduleTime <- value.scheduleTime,
            DBHelper.repeatCount <- value.repeatCount,
            DBHelper.repeatUnit <- value.repeatUnit,
            DBHelper.repeatInterval <- value.repeatInterval,
            DBHelper.enable <- value.enabled ? 1 : 0])
        return setter
    }

    func getAll() -> [LScheduledTransaction] {
        return super.getAll(by: DBHelper.scheduleTime.asc)
    }

    func deleteByAccount(id: Int64) -> Bool {
        var ret = false
        do {
            let delete = table!.filter(DBHelper.accountId == id).delete()
            try DBHelper.instance.db!.run(delete)
            ret = true
        } catch {
            LLog.e("\(self)", "DB deletion by account failed")
        }
        return ret
    }
}
