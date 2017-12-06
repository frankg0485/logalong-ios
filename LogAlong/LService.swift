//
//  LService.swift
//  LogAlong
//
//  Created by Michael Gao on 12/5/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LService {
    static let instance = LService()
    var pollingCount = 0

    func start() {
        LBroadcast.register(LBroadcast.ACTION_LOG_IN, cb: #selector(self.login), listener: self)
        LBroadcast.register(LBroadcast.ACTION_NEW_JOURNAL_AVAILABLE, cb: #selector(self.newJournalAvailable), listener: self)
        LBroadcast.register(LBroadcast.ACTION_PUSH_NOTIFICATION, cb: #selector(self.pushNotification), listener: self)
    }

    func stop() {
        LBroadcast.unregister(LBroadcast.ACTION_LOG_IN, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_NEW_JOURNAL_AVAILABLE, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_PUSH_NOTIFICATION, listener: self)
    }

    @objc func login(notification: Notification) -> Void {
        LJournal.instance.flush()
    }

    @objc func newJournalAvailable(notification: Notification) -> Void {
        LJournal.instance.flush()
    }

    @objc func pushNotification(notification: Notification) -> Void {
        LLog.d("\(self)", "poll upon push notification");
        //reset polling count upon receiving push notification from server
        //we'll keep polling up to MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION times, till a positive
        //polling result from server: this is to handle the case where server sends the notification
        //but underlying database hasn't got a chance to flush.
        pollingCount = 0;

        if !LJournal.instance.flush() {
            UiRequest.instance.UiPoll()
        }
    }

}
