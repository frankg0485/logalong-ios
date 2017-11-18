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

    static let userNameKey = "userName"
    static let userIdKey = "userId"

    static func getUserName() -> String {
        return defaults.string(forKey: userNameKey) ?? ""
    }

    static func setUserName(newName: String) {
        defaults.set(newName, forKey: userNameKey)
    }

    static func getUserId() -> String {
        return defaults.string(forKey: userIdKey) ?? ""
    }

    static func setUserId(newId: String) {
        return defaults.set(newId, forKey: userIdKey)
    }
}
