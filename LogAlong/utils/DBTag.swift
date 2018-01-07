//
//  DBTag.swift
//  LogAlong
//
//  Created by Michael Gao on 12/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import SQLite

class DBTag : DBGeneric<LTag> {
    static let instance = DBTag()

    override init() {
        super.init()
        table = DBHelper.instance.tags
        getValues = rdValues
        setValues = wrValues
    }

    private func rdValues(_ row: Row) -> LTag? {
        return LTag(id: row[DBHelper.id],
                         gid: row[DBHelper.gid],
                         name: row[DBHelper.name]!,
                         create: row[DBHelper.timestampCretae],
                         access: row[DBHelper.timestampAccess])
    }

    private func wrValues(_ value: LTag) -> [SQLite.Setter] {
        return [DBHelper.gid <- value.gid,
                DBHelper.name <- value.name,
                DBHelper.timestampCretae <- value.timestampCreate,
                DBHelper.timestampAccess <- value.timestampAccess]
    }

    func getAll() -> [LTag] {
        return super.getAll(by: DBHelper.name.asc)
    }
}
