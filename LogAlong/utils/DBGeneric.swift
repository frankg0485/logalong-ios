//
//  DBGeneric.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import SQLite

class DBGeneric {

    func get(_ table: Table, id: Int64) -> (gid: Int64, name: String)? {
        do {
            for entry in try DBHelper.instance.db!.prepare(table.filter(DBHelper.id == id)) {
                //TODO: error report if multiple entries found
                return (gid: entry[DBHelper.gid], name: entry[DBHelper.name])
            }
        } catch {
            LLog.e("\(self)", "unable to find entry with id: \(id)")
        }
        return nil
    }

    func get(_ table: Table, gid: Int64) -> (id: Int64, name: String)? {
        do {
            for entry in try DBHelper.instance.db!.prepare(table.filter(DBHelper.gid == gid)) {
                //TODO: error report if multiple entries found
                return (id: entry[DBHelper.id], name: entry[DBHelper.name])
            }
        } catch {
            LLog.e("\(self)", "unable to find entry with gid: \(gid)")
        }
        return nil
    }

    func add<T>(_ table: Table, dbase: inout T, name: String) -> Bool {
        var ret = false

        do {
            let insert = table.insert(DBHelper.name <- name, DBHelper.gid <- (dbase as! LDbBase).gid)
            let rowid = try DBHelper.instance.db!.run(insert)
            ret = (rowid != 0)
            (dbase as! LDbBase).id = rowid
        } catch {
            LLog.e("\(self)", "DB insert failed: \(error)")
        }

        return ret
    }

    func add<T>(_ table: Table, dbase: inout T, categoryId: Int64, accountId: Int64,
                amount: Double, timestamp: Int64, type: Int) -> Bool {
        var ret = false

        do {
            let insert = table.insert(DBHelper.categoryId <- categoryId,
                                      DBHelper.accountId <- accountId,
                                      DBHelper.amount <- amount,
                                      DBHelper.timestamp <- timestamp,
                                      DBHelper.type <- type)
            let rowid = try DBHelper.instance.db!.run(insert)
            ret = (rowid != 0)
            (dbase as! LDbBase).id = rowid
        } catch {
            LLog.e("\(self)", "DB insert failed")
        }

        return ret
    }

    func remove(_ table: Table, id: Int64) -> Bool {
        var ret = false

        do {
            let delete = table.filter(DBHelper.id == id).delete()
            try DBHelper.instance.db!.run(delete)
            ret = true
        } catch {
            LLog.e("\(self)", "DB deletion failed")
        }

        return ret
    }

    func update(_ table: Table, id: Int64, name: String) -> Bool {
        var ret = false

        do {
            let tab = table.filter(DBHelper.id == id)
            let update = tab.update(DBHelper.name <- name)

            try DBHelper.instance.db!.run(update)
            ret = true
        } catch {
            LLog.e("\(self)", "DB update failed")
        }

        return ret
    }

    func update(_ table: Table, id: Int64, accountId: Int64, categoryId: Int64,
                amount: Double, timestamp: Int64, type: Int) -> Bool {
        var ret = false

        do {
            let tab = table.filter(DBHelper.id == id)
            let update = tab.update(DBHelper.accountId <- accountId,
                                    DBHelper.categoryId <- categoryId,
                                    DBHelper.amount <- amount,
                                    DBHelper.timestamp <- timestamp,
                                    DBHelper.type <- type)

            try DBHelper.instance.db!.run(update)
            ret = true
        } catch {
            LLog.e("\(self)", "DB update failed")
        }

        return ret
    }
}
