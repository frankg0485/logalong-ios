//
//  DBVendor.swift
//  LogAlong
//
//  Created by Michael Gao on 12/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBVendor : DBGeneric<LVendor> {
    static let instance = DBVendor()

    override init() {
        super.init()
        table = DBHelper.instance.vendors
        getValues = rdValues
        setValues = wrValues
    }

    private func rdValues(_ row: Row) -> LVendor? {
        return LVendor(id: row[DBHelper.id],
                         gid: row[DBHelper.gid],
                         name: row[DBHelper.name]!,
                         type: VendorType(rawValue: UInt8(row[DBHelper.type]))!,
                         create: row[DBHelper.timestampCretae],
                         access: row[DBHelper.timestampAccess])
    }

    private func wrValues(_ value: LVendor) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name,
                DBHelper.type <- Int(value.type.rawValue),
                DBHelper.timestampCretae <- value.timestampCreate,
                DBHelper.timestampAccess <- value.timestampAccess]
    }

    func getAll() -> [LVendor] {
        return super.getAll(by: DBHelper.name.asc)
    }
}
