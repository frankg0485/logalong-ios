//
//  LBroadcast.swift
//  LogAlong
//
//  Created by Michael Gao on 11/18/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation
class LBroadcast {
    //public static final String EXTRA_RET_CODE = "ret"
    static let ACTION_BASE = "com.swoag.logalong.action."
    static let ACTION_USER_CREATED = 4
    static let ACTION_CONNECTED_TO_SERVER = 10
    static let ACTION_REQUESTED_TO_SHARE_ACCOUNT_WITH = 40

    static let ACTION_NETWORK_CONNECTED = 50
    static let ACTION_NETWORK_DISCONNECTED = 51
    static let ACTION_GET_USER_BY_NAME = 52
    static let ACTION_CREATE_USER = 54
    static let ACTION_SIGN_IN = 56
    static let ACTION_LOG_IN = 58
    static let ACTION_UPDATE_USER_PROFILE = 60
    static let ACTION_POST_JOURNAL = 62
    static let ACTION_POLL = 63
    static let ACTION_POLL_ACK = 64
    static let ACTION_NEW_JOURNAL_AVAILABLE = 300

    static let ACTION_UI_UPDATE_USER_PROFILE = 500
    static let ACTION_UI_UPDATE_ACCOUNT = 501
    static let ACTION_UI_UPDATE_CATEGORY = 502
    static let ACTION_UI_UPDATE_TAG = 503
    static let ACTION_UI_UPDATE_VENDOR = 504
    static let ACTION_UI_SHARE_ACCOUNT = 505
    static let ACTION_UI_NET_IDLE = 510
    static let ACTION_UI_NET_BUSY = 512
    static let ACTION_UI_RESET_PASSWORD = 515
    static let ACTION_UI_DB_DATA_CHANGED = 600
    static let ACTION_UI_DB_SEARCH_CHANGED = 601

    static let ACTION_REQUESTED_TO_SET_ACCOUNT_GID = 100
    static let ACTION_REQUESTED_TO_UPDATE_ACCOUNT_SHARE = 101
    static let ACTION_REQUESTED_TO_UPDATE_ACCOUNT_INFO = 102
    static let ACTION_REQUESTED_TO_UPDATE_SHARE_USER_PROFILE = 103
    static let ACTION_REQUESTED_TO_SHARE_TRANSITION_RECORD = 113
    static let ACTION_REQUESTED_TO_SHARE_TRANSITION_RECORDS = 114
    static let ACTION_REQUESTED_TO_SHARE_TRANSITION_CATEGORY = 115
    static let ACTION_REQUESTED_TO_SHARE_TRANSITION_PAYER = 116
    static let ACTION_REQUESTED_TO_SHARE_TRANSITION_TAG = 117
    static let ACTION_REQUESTED_TO_SHARE_PAYER_CATEGORY = 118
    static let ACTION_REQUESTED_TO_SHARE_SCHEDULE = 119

    static let ACTION_PUSH_NOTIFICATION = 7777
    static let ACTION_SERVER_BROADCAST_MSG_RECEIVED = 1000
    static let ACTION_UNKNOWN_MSG = 9999

    static func action(_ id: Int) -> Notification.Name {
        return Notification.Name(rawValue: ACTION_BASE + "\(id)")
    }

    static func post(_ id: Int, sender: Any? = nil, data: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: action(id), object: sender, userInfo: data)
        }
    }

    static func register(_ id: Int, cb: Selector, listener: Any) {
        NotificationCenter.default.addObserver(listener, selector: cb, name: action(id), object: nil)
    }

    static func unregister(_ id: Int, listener: Any) {
        NotificationCenter.default.removeObserver(listener, name: action(id), object: nil)
    }
}
