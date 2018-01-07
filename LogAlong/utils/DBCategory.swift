//
//  DBCategory.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBCategory : DBGeneric<LCategory> {
    static let instance = DBCategory()

    override init() {
        super.init()
        table = DBHelper.instance.categories
        getValues = rdValues
        setValues = wrValues
    }

    private func rdValues(_ row: Row) -> LCategory? {
        return LCategory(id: row[DBHelper.id],
                         gid: row[DBHelper.gid],
                         name: row[DBHelper.name]!,
                         create: row[DBHelper.timestampCretae],
                         access: row[DBHelper.timestampAccess])
    }

    private func wrValues(_ value: LCategory) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name,
                DBHelper.timestampCretae <- value.timestampCreate,
                DBHelper.timestampAccess <- value.timestampAccess]
    }

    func getAll() -> [LCategory] {
        return super.getAll(by: DBHelper.name.asc)
    }
}
