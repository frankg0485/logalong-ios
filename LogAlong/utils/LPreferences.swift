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

    static func getRecordsSearchControls() -> LRecordSearch {
        return LRecordSearch(from: 0, to: 0)
    }

    static func setRecordsSearchControls(controls: LRecordSearch) {

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

    static func getShareUserName(_ gid: Int64) -> String {
        return defaults.string(forKey: "\(userName).\(String(gid))")!
    }

    static func getShareUserId(_ gid: Int64) -> String {
        return defaults.string(forKey: "\(userId).\(String(gid))")!
    }

    static func setShareUserName(_ gid: Int64, _ fullName: String) {
        defaults.set(fullName, forKey: "\(userName).\(String(gid))")
    }

    static func setShareUserId(_ gid: Int64, _ id: String) {
        defaults.set(id, forKey: "\(userId).\(String(gid))")
    }

    static func getShareAccept(_ uid: Int64) -> Int{
        return defaults.integer(forKey: shareAccept + "." + String(uid))
    }

    static func setShareAccept(_ uid: Int64, _ acceptTimeMs: Int64) {
        return defaults.set(acceptTimeMs, forKey: shareAccept + "." + String(uid))
    }
}
