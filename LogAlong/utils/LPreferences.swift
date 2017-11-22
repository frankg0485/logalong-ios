//
//  LPreferences.swift
//  LogAlong
//
//  Created by Frank Gao on 11/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation
import UIKit

class LPreferences {
    static let defaults = UserDefaults.standard

    static let loginError = "LoginError"
    static let userIdNum = "userIdNum"
    static let userLoginNum = "userLoginNum"
    static let userName = "userName"

    static func getUserName() -> String {
        return defaults.string(forKey: userName) ?? ""
    }

    static func setUserName(_ val: String) {
        defaults.set(val, forKey: userName)
    }
    /*
     static func getUserIdNum() -> UInt64 {
     return defaults.object(forKey: userIdNum) as! UInt64
     }

     static func setUserIdNum(_ val: UInt64) {
     return defaults.set(val, forKey: userIdNum)
     }

     static func getUserLoginNum() -> UInt64 {
     return defaults.object(forKey: userLoginNum) as! UInt64
     }

     static func setUserLoginNum(_ val: UInt64) {
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
