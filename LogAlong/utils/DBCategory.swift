//
//  DBCategory.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

class DBCategory : DBGeneric {
    static let instance = DBCategory()

    func getAll() -> [LCategory] {
        var categories: [LCategory] = []

        do {
            for category in try DBHelper.instance.db!.prepare(DBHelper.instance.categories.order(DBHelper.name.asc)) {
                categories.append(LCategory(id: category[DBHelper.id], gid: 0, name: category[DBHelper.name]))
            }
        } catch {
            LLog.e("\(self)", "Select all category failed")
        }

        return categories
    }

    func get(id: Int64) -> LCategory? {
        if let ret: (gid: Int64, name: String) = super.get(DBHelper.instance.categories, id: id) {
            return LCategory(id: id, gid: ret.gid, name: ret.name)
        } else {
            return nil
        }
    }

    func add(_ category: inout LCategory) -> Bool {
        return super.add(DBHelper.instance.categories, dbase: &category, name: category.name)
    }

    func remove(id: Int64) -> Bool {
        return super.remove(DBHelper.instance.categories, id: id)
    }

    func update(_ category: LCategory) -> Bool {
        return super.update(DBHelper.instance.categories, id: category.id, name: category.name)
    }
}
