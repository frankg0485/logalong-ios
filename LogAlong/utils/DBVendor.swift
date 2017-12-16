//
//  DBVendor.swift
//  LogAlong
//
//  Created by Michael Gao on 12/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBVendor : DBGeneric {
    static let instance = DBVendor()
    private let table = DBHelper.instance.vendors

    private func getValues(_ row: Row) -> LVendor? {
        return LVendor(id: row[DBHelper.id],
                         gid: row[DBHelper.gid],
                         name: row[DBHelper.name],
                         type: VendorType(rawValue: UInt8(row[DBHelper.type]))!)
    }

    private func setValues(_ value: LVendor) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name,
                DBHelper.type <- Int(value.type.rawValue)]
    }

    func getAll() -> [LVendor] {
        return super.getAll(table, getValues, by: DBHelper.name.asc)
    }

    func get(id: Int64) -> LVendor? {
        return super.get(table, getValues, id: id)
    }

    func get(gid: Int64) -> LVendor? {
        return super.get(table, getValues, gid: gid)
    }

    func add(_ vendor: inout LVendor) -> Bool {
        return super.add(table, setValues, &vendor)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(table, id: id)
    }

    func update(_ vendor: LVendor) -> Bool {
        return super.update(table, setValues, vendor)
    }
}
