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

    static let instance = LPreferences()
    let defaults = UserDefaults.standard

    let userNameKey = "userName"
    let userIdKey = "userId"

    func getUserName() -> String {
        return defaults.string(forKey: userNameKey) ?? ""
    }

    func setUserName(newName: String) {
        defaults.set(newName, forKey: userNameKey)
    }

    func getUserId() -> String {
        return defaults.string(forKey: userIdKey) ?? ""
    }

    func setUserId(newId: String) {
        return defaults.set(newId, forKey: userIdKey)
    }
}
