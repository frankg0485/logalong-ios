//
//  LRecordSearch.swift
//  LogAlong
//
//  Created by Michael Gao on 1/2/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import Foundation

struct LRecordSearch {
    var all: Bool
    var allTime: Bool
    var from: Int64
    var to: Int64
    var byEditTime: Bool
    var byValue: Bool
    var value: Double
    var accounts: [Int64]
    var categories: [Int64]
    var vendors: [Int64]
    var tags: [Int64]
}
