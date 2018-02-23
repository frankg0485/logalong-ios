//
//  LScheduledTransaction.swift
//  LogAlong
//
//  Created by Michael Gao on 12/17/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LScheduledTransaction: LTransaction {
    static let START_HOUR_OF_DAY = 2
    static let REPEAT_UNIT_WEEK = 10
    static let REPEAT_UNIT_MONTH = 20

    var scheduleTime: Int64
    var repeatCount: Int
    var repeatUnit: Int
    var repeatInterval: Int
    var enabled: Bool

    override init() {
        scheduleTime = 0
        repeatCount = 1 //unlimited
        repeatUnit = LScheduledTransaction.REPEAT_UNIT_MONTH
        repeatInterval = 1
        enabled = true
        super.init()
    }

    init(scheduleTime: Int64, repeatCount: Int, repeatUnit: Int, repeatInterval: Int, enabled: Bool, trans: LTransaction?) {
        self.scheduleTime = scheduleTime
        self.repeatCount = repeatCount
        self.repeatInterval = repeatInterval
        self.repeatUnit = repeatUnit
        self.enabled = enabled

        if let tr = trans {
            super.init(trans: tr)
        } else {
            super.init()
        }
    }

    init(schedule: LScheduledTransaction) {
        scheduleTime = schedule.scheduleTime
        repeatCount = schedule.repeatCount
        repeatUnit = schedule.repeatUnit
        repeatInterval = schedule.repeatInterval
        enabled = schedule.enabled
        super.init(trans: schedule)
    }

    func initNextTimeMs() {
        var baseTimeMs = timestamp

        let cdate = Date(milliseconds: baseTimeMs)
        let calendar = Calendar.current
        var comp = calendar.dateComponents(in: calendar.timeZone, from: cdate)
        comp.hour = LScheduledTransaction.START_HOUR_OF_DAY
        comp.minute = 0
        comp.second = 0
        let date = calendar.date(from: comp)!
        baseTimeMs = date.currentTimeMillis

        let curTimeMs = Date().currentTimeMillis
        if (baseTimeMs > curTimeMs || (curTimeMs - baseTimeMs < Int64(24 * 3600 * 1000))) {
            scheduleTime = baseTimeMs
        } else if (0 == repeatCount) {
            //reset to today
            let cdate = Date(milliseconds: baseTimeMs)
            let calendar = Calendar.current
            var comp = calendar.dateComponents(in: calendar.timeZone, from: cdate)
            comp.hour = LScheduledTransaction.START_HOUR_OF_DAY
            comp.minute = 0
            comp.second = 0
            let date = calendar.date(from: comp)!
            baseTimeMs = date.currentTimeMillis

            timestamp = baseTimeMs
            scheduleTime = baseTimeMs
        } else {
            nextTimeMs();
        }
    }

    private func nextTimeMs() {
        var baseTimeMs = timestamp

        // always align time to 00:00:00 of the day
        let cdate = Date(milliseconds: baseTimeMs)
        let calendar = Calendar.current
        var comp = calendar.dateComponents(in: calendar.timeZone, from: cdate)
        comp.hour = LScheduledTransaction.START_HOUR_OF_DAY
        comp.minute = 0
        comp.second = 0
        var date = calendar.date(from: comp)!
        baseTimeMs = date.currentTimeMillis

        if (repeatInterval == 0) {
            repeatInterval = 1 //JIC
        }

        while (baseTimeMs <= Date().currentTimeMillis) {
            if (repeatUnit == LScheduledTransaction.REPEAT_UNIT_MONTH) {
                let date2 = calendar.date(byAdding: .month, value: repeatInterval, to: date)
                baseTimeMs = date2!.currentTimeMillis
                date = date2!
            } else {
                baseTimeMs += Int64(repeatInterval * 7 * 24 * 3600 * 1000)
            }
        }
        scheduleTime = baseTimeMs;
    }
}
