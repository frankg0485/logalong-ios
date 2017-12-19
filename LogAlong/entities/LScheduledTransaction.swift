//
//  LScheduledTransaction.swift
//  LogAlong
//
//  Created by Michael Gao on 12/17/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LScheduledTransaction: LTransaction {
    var scheduleTime: Int64
    var repeatCount: Int
    var repeatUnit: Int
    var repeatInterval: Int
    var enabled: Bool

    override init() {
        scheduleTime = 0
        repeatCount = 0
        repeatUnit = 0
        repeatInterval = 0
        enabled = true
        super.init()
    }
}
