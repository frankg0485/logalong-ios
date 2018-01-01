//
//  DBLoader.swift
//  LogAlong
//
//  Created by Michael Gao on 12/30/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class DBLoader {
    static let instance = DBLoader()
    private var table = DBHelper.instance.transactions

    func getStartEndTime() -> (startMs: Int64, endMs: Int64) {
        let queryStart = table.select(DBHelper.timestamp).order(DBHelper.timestamp.asc).limit(1)
        let queryEnd = table.select(DBHelper.timestamp).order(DBHelper.timestamp.desc).limit(1)
        var start: Int64 = 0
        var end: Int64 = 0

        do {
            for row in try DBHelper.instance.db!.prepare(queryStart) {
                start = row[DBHelper.timestamp]
            }

            for row in try DBHelper.instance.db!.prepare(queryEnd) {
                end = row[DBHelper.timestamp]
            }
        } catch {
            LLog.e("\(self)", "unable to find valid row")
        }

        return (start, end)
    }
}
