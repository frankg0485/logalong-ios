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

    func getAll() -> [LAccount] {
        var accounts: [LAccount] = []

        do {
            for account in try DBHelper.instance.db!.prepare(DBHelper.instance.accounts.order(DBHelper.name.asc)) {
                accounts.append(LAccount(id: account[DBHelper.id], gid: 0, name: account[DBHelper.name]))
            }
        } catch {
            LLog.e("\(self)", "Get all accounts failed")
        }

        return accounts
    }

    func get(id: Int64) -> LAccount? {
        if let ret: (gid: Int64, name: String) = super.get(DBHelper.instance.accounts, id: id) {
            return LAccount(id: id, gid: ret.gid, name: ret.name)
        } else {
            return nil
        }
    }

    func add(_ account: inout LAccount) -> Bool {
        return super.add(DBHelper.instance.accounts, dbase: &account, name: account.name)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(DBHelper.instance.accounts, id: id)
    }

    func update(_ account: LAccount) -> Bool {
        return super.update(DBHelper.instance.accounts, id: account.id, name: account.name)
    }
}
