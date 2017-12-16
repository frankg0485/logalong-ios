//
//  DBTag.swift
//  LogAlong
//
//  Created by Michael Gao on 12/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBTag : DBGeneric {
    static let instance = DBTag()
    private let table = DBHelper.instance.tags

    private func getValues(_ row: Row) -> LTag? {
        return LTag(id: row[DBHelper.id],
                         gid: row[DBHelper.gid],
                         name: row[DBHelper.name])
    }

    private func setValues(_ value: LTag) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name]
    }

    func getAll() -> [LTag] {
        return super.getAll(table, getValues, by: DBHelper.name.asc)
    }

    func get(id: Int64) -> LTag? {
        return super.get(table, getValues, id: id)
    }

    func get(gid: Int64) -> LTag? {
        return super.get(table, getValues, gid: gid)
    }

    func add(_ tag: inout LTag) -> Bool {
        return super.add(table, setValues, &tag)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(table, id: id)
    }

    func update(_ tag: LTag) -> Bool {
        return super.update(table, setValues, tag)
    }
}
