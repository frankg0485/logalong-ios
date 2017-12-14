//
//  DBAccount.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBAccount : DBGeneric {
    static let instance = DBAccount()
    private let table = DBHelper.instance.accounts

    private func getValues(_ row: Row) -> LAccount? {
        return LAccount(id: row[DBHelper.id],
                        gid: row[DBHelper.gid],
                        name: row[DBHelper.name],
                        share: row[DBHelper.share],
                        showBalance: row[DBHelper.showBalance] != 0,
                        create: row[DBHelper.timestampCretae],
                        access: row[DBHelper.timestampAccess])
    }

    private func setValues(_ value: LAccount) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name,
                DBHelper.share <- value.share,
                DBHelper.showBalance <- (value.showBalance ? 1 : 0),
                DBHelper.timestampCretae <- value.timestampCreate,
                DBHelper.timestampAccess <- value.timestampAccess]
    }

    func getAll() -> [LAccount] {
        return super.getAll(table, getValues, by: DBHelper.name.asc)
    }

    func get(id: Int64) -> LAccount? {
        return super.get(table, getValues, id: id)
    }

    func get(gid: Int64) -> LAccount? {
        return super.get(table, getValues, gid: gid)
    }

    func add(_ account: inout LAccount) -> Bool {
        return super.add(table, setValues, &account)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(table, id: id)
    }

    func update(_ account: LAccount) -> Bool {
        return super.update(table, setValues, account)
    }
}
