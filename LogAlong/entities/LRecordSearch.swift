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
    var allValue: Bool
    var fromValue: Double
    var toValue: Double
    var accounts: [Int64]
    var categories: [Int64]
    var vendors: [Int64]
    var tags: [Int64]
    var types: [Int64]
    var searchAccounts: Bool
    var searchCategories: Bool
    var searchVendors: Bool
    var searchTags: Bool
    var searchTypes: Bool
}
