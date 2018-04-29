//
//  LPreferences.swift
//  LogAlong
//
//  Created by Frank Gao on 11/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation
import UIKit

// UserDefaults is thread safe
class LPreferences {
    static let defaults = UserDefaults.standard

    static let loginError = "LoginError"
    static let recordsViewTimeInterval = "recordsViewTimeInterval"
    static let recordsViewSortMode = "recordsViewSortMode"
    static let recordsViewAscend = "recordsViewAscend"
    static let recordsSearchControls = "recordsSearchControls"
    static let userIdNum = "userIdNum"
    static let userLoginNum = "userLoginNum"
    static let userId = "userId"
    static let userName = "userName"
    static let userPassword = "userPassword"
    static let shareAccept = "shareAccept"
    static let shareAccountRequest = "shareAccountRequest"
    static let lastSavedValues = "lastSavedValues"

    static func getRecordsSearchControls() -> LRecordSearch {
        let defaultTo: Int64 = Date().currentTimeMillis
        let defaultFrom: Int64 = defaultTo - Int64(4 * 7 * 24 * 3600 * 1000)

        let all: Bool = (defaults.object(forKey: recordsSearchControls + ".all") ?? true) as! Bool
        let allTime: Bool = (defaults.object(forKey: recordsSearchControls + ".allTime") ?? true) as! Bool
        var from: Int64 = (defaults.object(forKey: recordsSearchControls + ".from") ?? defaultFrom) as! Int64
        var to: Int64 = (defaults.object(forKey: recordsSearchControls + ".to") ?? defaultTo) as! Int64
        if (to < from) { swap(&to, &from) }

        let byEditTime: Bool = (defaults.object(forKey: recordsSearchControls + ".byEditTime") ?? false) as! Bool
        let allValue: Bool = (defaults.object(forKey: recordsSearchControls + ".allValue") ?? true) as! Bool

        var fromValue: Double = (defaults.object(forKey: recordsSearchControls + ".fromValue") ?? Double(0)) as! Double
        var toValue: Double = (defaults.object(forKey: recordsSearchControls + ".toValue") ?? Double(0)) as! Double
        if (toValue < fromValue) && (toValue != 0) { swap(&toValue, &fromValue) }

        let accounts: [Int64] = (defaults.array(forKey: recordsSearchControls + ".accounts") ?? [Int64]()) as! [Int64]
        let categories: [Int64] = (defaults.array(forKey: recordsSearchControls + ".categories") ?? [Int64]()) as! [Int64]
        let vendors: [Int64] = (defaults.array(forKey: recordsSearchControls + ".vendors") ?? [Int64]()) as! [Int64]
        let tags: [Int64] = (defaults.array(forKey: recordsSearchControls + ".tags") ?? [Int64]()) as! [Int64]
        let searchAccounts: Bool = (defaults.object(forKey: recordsSearchControls + ".searchAccounts") ?? true) as! Bool
        let searchCategories: Bool = (defaults.object(forKey: recordsSearchControls + ".searchCategories") ?? true) as! Bool
        let searchVendors: Bool = (defaults.object(forKey: recordsSearchControls + ".searchVendors") ?? true) as! Bool
        let searchTags: Bool = (defaults.object(forKey: recordsSearchControls + ".searchTags") ?? true) as! Bool

        return LRecordSearch(all: all, allTime: allTime, from: from, to: to, byEditTime: byEditTime, allValue: allValue, fromValue: fromValue, toValue: toValue,
                             accounts: accounts, categories: categories, vendors: vendors, tags: tags, searchAccounts: searchAccounts, searchCategories: searchCategories, searchVendors: searchVendors, searchTags: searchTags)
    }

    static func setRecordsSearchControls(controls: LRecordSearch) {
        defaults.set(controls.all, forKey: recordsSearchControls + ".all")
        defaults.set(controls.allTime, forKey: recordsSearchControls + ".allTime")
        defaults.set(controls.from, forKey: recordsSearchControls + ".from")
        defaults.set(controls.to, forKey: recordsSearchControls + ".to")
        defaults.set(controls.byEditTime, forKey: recordsSearchControls + ".byEditTime")
        defaults.set(controls.allValue, forKey: recordsSearchControls + ".allValue")
        defaults.set(controls.fromValue, forKey: recordsSearchControls + ".fromValue")
        defaults.set(controls.toValue, forKey: recordsSearchControls + ".toValue")

        defaults.set(controls.accounts, forKey: recordsSearchControls + ".accounts")
        defaults.set(controls.categories, forKey: recordsSearchControls + ".categories")
        defaults.set(controls.vendors, forKey: recordsSearchControls + ".vendors")
        defaults.set(controls.tags, forKey: recordsSearchControls + ".tags")
        defaults.set(controls.searchAccounts, forKey: recordsSearchControls + ".searchAccounts")
        defaults.set(controls.searchCategories, forKey: recordsSearchControls + ".searchCategories")
        defaults.set(controls.searchVendors, forKey: recordsSearchControls + ".searchVendors")
        defaults.set(controls.searchTags, forKey: recordsSearchControls + ".searchTags")
    }

    static func getRecordsViewAscend() -> Bool {
        return defaults.bool(forKey: recordsViewAscend)
    }

    static func setRecordsViewAscend(_ val: Bool) {
        defaults.set(val, forKey: recordsViewAscend)
    }

    static func getRecordsViewTimeInterval() -> Int {
        let v = defaults.integer(forKey: recordsViewTimeInterval)
        return v == 0 ? RecordsViewInterval.MONTHLY.rawValue : v
    }

    static func setRecordsViewTimeInterval(_ val: Int) {
        defaults.set(val, forKey: recordsViewTimeInterval)
    }

    static func getRecordsViewSortMode() -> Int {
        let v = defaults.integer(forKey: recordsViewSortMode)
        return v == 0 ? RecordsViewSortMode.TIME.rawValue : v
    }

    static func setRecordsViewSortMode(_ val: Int) {
        defaults.set(val, forKey: recordsViewSortMode)
    }

    static func getUserId() -> String {
        return defaults.string(forKey: userId) ?? ""
    }

    static func setUserId(_ val: String) {
        defaults.set(val, forKey: userId)
    }

    static func getUserName() -> String {
        return defaults.string(forKey: userName) ?? ""
    }

    static func setUserName(_ val: String) {
        defaults.set(val, forKey: userName)
    }

    static func getUserPassword() -> String {
        return defaults.string(forKey: userPassword) ?? ""
    }

    static func setUserPassword(_ val: String) {
        defaults.set(val, forKey: userPassword)
    }

    static func getUserIdNum() -> Int {
        return defaults.integer(forKey: userIdNum)
    }

    static func setUserIdNum(_ val: Int) {
        return defaults.set(val, forKey: userIdNum)
    }

    static func getUserLoginNum() -> Int {
        return defaults.integer(forKey: userLoginNum)
    }

    static func setUserLoginNum(_ val: Int) {
        return defaults.set(val, forKey: userLoginNum)
    }

    static func getLoginError() -> Bool {
        return defaults.bool(forKey: loginError)
    }

    static func setLoginError(_ val: Bool) {
        return defaults.set(val, forKey: loginError)
    }

    static func getDeviceId() -> String {
        let uniqueId = UIDevice.current.identifierForVendor?.uuidString
        return uniqueId!
    }

    static func getShareUserName(_ gid: Int64) -> String? {
        return defaults.string(forKey: "\(userName).\(String(gid))")
    }

    static func getShareUserId(_ gid: Int64) -> String? {
        return defaults.string(forKey: "\(userId).\(String(gid))")
    }

    static func setShareUserName(_ gid: Int64, _ fullName: String) {
        defaults.set(fullName, forKey: "\(userName).\(String(gid))")
    }

    static func setShareUserId(_ gid: Int64, _ id: String) {
        defaults.set(id, forKey: "\(userId).\(String(gid))")
    }

    static func getShareAccept(_ uid: Int64) -> Int64 {
        return (defaults.object(forKey: shareAccept + "." + String(uid)) ?? Int64(0)) as! Int64
    }

    static func setShareAccept(_ uid: Int64, _ acceptTimeS: Int64) {
        return defaults.set(acceptTimeS, forKey: shareAccept + "." + String(uid))
    }

    static func setLastSavedValues(_ savedValues: [String : Int64]) {
        defaults.set(savedValues, forKey: lastSavedValues)
    }

    static func getLastSavedValues() -> [String : Int64]? {
        return defaults.object(forKey: lastSavedValues) as? [String : Int64]
    }

    static func getEmptyAccountShareRequest() -> Int {
        let shares = defaults.integer(forKey: shareAccountRequest + ".total")

        var ii = 0
        while ii < shares {
            if (defaults.integer(forKey: shareAccountRequest + String(ii) + ".state") == 0) {
                return ii
            }
            ii += 1
        }

        defaults.set(shares + 1, forKey: shareAccountRequest + ".total")
        return ii
    }

    static func addAccountShareRequest(_ request: LAccountShareRequest) {
        let share = getEmptyAccountShareRequest()

        defaults.set(request.accountName, forKey: shareAccountRequest + String(share) + ".accountName")
        defaults.set(request.accountGid, forKey: shareAccountRequest + String(share) + ".accountGid")
        defaults.set(request.userId, forKey: shareAccountRequest + String(share) + ".userId")
        defaults.set(request.userName, forKey: shareAccountRequest + String(share) + ".userName")
        defaults.set(request.userFullName, forKey: shareAccountRequest + String(share) + ".userFullName")
        defaults.set(1, forKey: shareAccountRequest + String(share) + ".state")
    }

    static func deleteAccountShareRequest(request: LAccountShareRequest) {
        let shares = defaults.integer(forKey: shareAccountRequest + ".total")

        var ii = 0
        while ii < shares {
            if defaults.integer(forKey: shareAccountRequest + String(ii) + ".state") == 1 {
                if (defaults.integer(forKey: shareAccountRequest + String(ii) + ".userId") == Int(request.userId))
                    && (defaults.string(forKey: shareAccountRequest + String(ii) + ".userName") == request.userName)
                    && (defaults.string(forKey: shareAccountRequest + String(ii) + ".userFullName") == request.userFullName)
                    && (defaults.string(forKey: shareAccountRequest + String(ii) + ".accountName") == request.accountName)
                    && (defaults.integer(forKey: shareAccountRequest + String(ii) + ".accountGid") == Int(request.accountGid)) {
                    defaults.set(0, forKey: shareAccountRequest + String(ii) + ".state")
                    //TODO: fix multiple poll problem here
                    //break
                }
            }
            ii += 1
        }
    }

    static func getAccountShareRequest() -> LAccountShareRequest? {
        var request: LAccountShareRequest? = nil
        let shares = defaults.integer(forKey: shareAccountRequest + ".total")

        var ii = 0
        while ii < shares {
            if defaults.integer(forKey: shareAccountRequest + String(ii) + ".state") == 1 {
                request = LAccountShareRequest(userId: Int64(defaults.integer(forKey: shareAccountRequest + String(ii) + ".userId")), userName: defaults.string(forKey: shareAccountRequest + String(ii) + ".userName"), userFullName: defaults.string(forKey: shareAccountRequest + String(ii) + ".userFullName"), accountName: defaults.string(forKey: shareAccountRequest + String(ii) + ".accountName"), accountGid: Int64(defaults.integer(forKey: shareAccountRequest + String(ii) + ".accountGid")))
                if request != nil {
                    break
                }
            }
            ii += 1
        }
        return request
    }
}
