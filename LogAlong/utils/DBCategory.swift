//
//  DBCategory.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBCategory : DBGeneric {
    static let instance = DBCategory()
    private let table = DBHelper.instance.categories

    private func getValues(_ row: Row) -> LCategory? {
        return LCategory(id: row[DBHelper.id],
                         gid: row[DBHelper.gid],
                         name: row[DBHelper.name])
    }

    private func setValues(_ value: LCategory) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name]
    }

    func getAll() -> [LCategory] {
        return super.getAll(table, getValues, by: DBHelper.name.asc)
    }

    func get(id: Int64) -> LCategory? {
        return super.get(table, getValues, id: id)
    }

    func get(gid: Int64) -> LCategory? {
        return super.get(table, getValues, gid: gid)
    }

    func add(_ category: inout LCategory) -> Bool {
        return super.add(table, setValues, &category)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(table, id: id)
    }

    func update(_ category: LCategory) -> Bool {
        return super.update(table, setValues, category)
    }
}
