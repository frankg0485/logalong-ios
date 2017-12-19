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
                         name: row[DBHelper.name],
                         type: VendorType(rawValue: UInt8(row[DBHelper.type]))!)
    }

    private func wrValues(_ value: LVendor) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name,
                DBHelper.type <- Int(value.type.rawValue)]
    }

    func getAll() -> [LVendor] {
        return super.getAll(by: DBHelper.name.asc)
    }
}
