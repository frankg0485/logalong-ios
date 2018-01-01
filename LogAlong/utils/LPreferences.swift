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
    static let userIdNum = "userIdNum"
    static let userLoginNum = "userLoginNum"
    static let userId = "userId"
    static let userName = "userName"
    static let userPassword = "userPassword"

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

    /*
     static func getUserIdNum() -> Int64 {
     return defaults.object(forKey: userIdNum) as! Int64
     }

     static func setUserIdNum(_ val: Int64) {
     return defaults.set(val, forKey: userIdNum)
     }

     static func getUserLoginNum() -> Int64 {
     return defaults.object(forKey: userLoginNum) as! Int64
     }

     static func setUserLoginNum(_ val: Int64) {
     return defaults.set(val, forKey: userLoginNum)
     }
     */
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
}
