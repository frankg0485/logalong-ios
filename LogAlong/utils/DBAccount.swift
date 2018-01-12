//
//  DBAccount.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBAccount : DBGeneric<LAccount> {
    static let instance = DBAccount()

    override init() {
        super.init()
        table = DBHelper.instance.accounts
        getValues = rdValues
        setValues = wrValues
    }

    private func rdValues(_ row: Row) -> LAccount? {
        return LAccount(id: row[DBHelper.id],
                        gid: row[DBHelper.gid],
                        name: row[DBHelper.name]!,
                        share: row[DBHelper.share],
                        showBalance: row[DBHelper.showBalance] != 0,
                        create: row[DBHelper.timestampCretae],
                        access: row[DBHelper.timestampAccess])
    }

    private func wrValues(_ value: LAccount) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name,
                DBHelper.share <- value.share,
                DBHelper.showBalance <- (value.showBalance ? 1 : 0),
                DBHelper.timestampCretae <- value.timestampCreate,
                DBHelper.timestampAccess <- value.timestampAccess]
    }

    func getAll() -> [LAccount] {
        return super.getAll(by: DBHelper.name.asc)
    }

    func getAllShareUser() -> Set<Int64> {
        var users: Set<Int64> = []

        for account in self.getAll() {
            let str = account.share
            if !str.isEmpty {
                account.setSharedIdsString(str)
                if !account.shareIds.isEmpty {
                    for ii in account.shareIds {
                        users.insert(ii)
                    }
                }
            }
        }
        return users
    }
}
