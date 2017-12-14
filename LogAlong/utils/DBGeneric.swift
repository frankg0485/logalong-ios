//
//  DBGeneric.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import SQLite

class DBGeneric {
    func getAll<T>(_ table: Table, _ getValues: (Row) -> T?, by: Expressible...) -> [T] {
        var ts: [T] = []

        do {
            for row in try DBHelper.instance.db!.prepare(table.order(by)) {
                ts.append(getValues(row)!)
            }
        } catch {
            LLog.e("\(self)", "Get all rows failed")
        }

        return ts
    }

    func get<T>(_ table: Table, _ getValues: (Row) -> T?, id: Int64) -> T? {
        do {
            for row in try DBHelper.instance.db!.prepare(table.filter(DBHelper.id == id)) {
                //TODO: error report if multiple entries found
                return getValues(row)
            }
        } catch {
            LLog.e("\(self)", "unable to find row with id: \(id)")
        }
        return nil
    }

    func get<T>(_ table: Table, _ getValues: (Row) -> T?, gid: Int64) -> T? {
        do {
            for row in try DBHelper.instance.db!.prepare(table.filter(DBHelper.gid == gid)) {
                //TODO: error report if multiple entries found
                return getValues(row)
            }
        } catch {
            LLog.e("\(self)", "unable to find row with gid: \(gid)")
        }
        return nil
    }

    func add<T>(_ table: Table, _ setValues: (T) -> [SQLite.Setter], _ dbase: inout T) -> Bool {
        var ret = false

        do {
            let insert = table.insert(setValues(dbase))
            let rowid = try DBHelper.instance.db!.run(insert)
            ret = (rowid != 0)
            (dbase as! LDbBase).id = rowid
        } catch {
            LLog.e("\(self)", "DB insert failed: \(error)")
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

    func update<T>(_ table: Table, _ setValues: (T) -> [SQLite.Setter], _ dbase: T) -> Bool {
        var ret = false

        do {
            let tab = table.filter(DBHelper.id == (dbase as! LDbBase).id)
            let update = tab.update(setValues(dbase))

            try DBHelper.instance.db!.run(update)
            ret = true
        } catch {
            LLog.e("\(self)", "DB update failed")
        }

        return ret
    }
}
