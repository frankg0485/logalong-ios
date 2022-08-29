//
//  DBJournal.swift
//  LogAlong
//
//  Created by Michael Gao on 12/1/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import SQLite

class DBJournal {
    static let instance = DBJournal()
    let table = DBHelper.instance.journals

    func get() -> LJournalEntry? {
        do {
            if let row = try DBHelper.instance.db!.pluck(table) {
                return LJournalEntry(journalId: row[DBHelper.journalId], data: [UInt8](row[DBHelper.data]))
            }
        }catch {
            LLog.d("\(self)", "unable to get journal entry")
        }
        return nil
    }

    func add(_ journal: LJournalEntry) -> Bool {
        var ret = false

        do {
            let insert = table.insert(DBHelper.journalId <- journal.journalId,
                                      DBHelper.data <- Data(journal.data))
            let rowid = try DBHelper.instance.db!.run(insert)
            ret = (rowid != 0)
        } catch {
            LLog.e("\(self)", "journal insert failed")
        }

        return ret
    }

    @discardableResult func remove(id: Int) -> Bool {
        var ret = false

        do {
            if let row = try DBHelper.instance.db!.pluck(table) {
                if id == row[DBHelper.journalId] {
                    do {
                        let delete = table.filter(DBHelper.id == row[DBHelper.id]).delete()
                        try DBHelper.instance.db!.run(delete)
                        ret = true
                    } catch {
                        LLog.e("\(self)", "DB deletion failed")
                    }
                } else {
                    LLog.w("\(self)", "journal ID mismatch present upon removing")
                }
            }
        } catch {
            LLog.w("\(self)", "unable to get journal entry upon removing")
        }

        return ret
    }
}
