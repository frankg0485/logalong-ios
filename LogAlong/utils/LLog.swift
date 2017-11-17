//
//  LLog.swift
//  LogAlong
//
//  Created by Michael Gao on 11/16/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LLog {
    static let debug = true;
    static let localLog = true;
    static let netLog = false;
    static var lastMsg = "";
    static var repeatCount = 0;

    static func d(_ tag: String, _ message: String) {
        print(tag + ":" + message)
    }

    static func e(_ tag: String, _ message: String) {
        print(tag + ":" + message)
    }

    static func w(_ tag: String, _ message: String) {
        print(tag + ":" + message)
    }

    static func i(_ tag: String, _ message: String) {
        print(tag + ":" + message)
    }
}
