//
//  LJournal.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import Foundation

class LJournal {
    static let MAX_JOURNAL_LENGTH = 512
    static let instance = LJournal()

    var journalId: Int = 0
    var data = LBuffer(size: LJournal.MAX_JOURNAL_LENGTH)
    private var postCount = 0;
    private var flushCount = 0;

    func flush() {

    }

    /*
     public boolean getAllAccounts() {
     return post(LProtocol.JRQST_GET_ACCOUNTS);
     }

     public boolean getAllCategories() {
     return post(LProtocol.JRQST_GET_CATEGORIES);
     }

     public boolean getAllTags() {
     return post(LProtocol.JRQST_GET_TAGS);
     }

     public boolean getAllVendors() {
     return post(LProtocol.JRQST_GET_VENDORS);
     }

     public boolean getAllRecords() {
     //return post(LProtocol.JRQST_GET_RECORDS);
     return getRecords(null);
     }

     public boolean getAllSchedules() {
     return post(LProtocol.JRQST_GET_SCHEDULES);
     }

     public boolean getAccountRecords(long aid) {
     return postById(aid, LProtocol.JRQST_GET_ACCOUNT_RECORDS);
     }

     public boolean getAccountSchedules(long aid) {
     return postById(aid, LProtocol.JRQST_GET_ACCOUNT_SCHEDULES);
     }

     public boolean getAccountUsers(long aid) {
     return postById(aid, LProtocol.JRQST_GET_ACCOUNT_USERS);
     }

     public boolean getRecord(long id) {
     return postById(id, LProtocol.JRQST_GET_RECORD);
     }

     public boolean getRecords(long ids[]) {
     data.clear();
     data.putShortAutoInc(LProtocol.JRQST_GET_RECORDS);
     if (null == ids) {
     data.putShortAutoInc((short) 0); // get all records;
     } else {
     data.putShortAutoInc((short) ids.length);
     for (long id : ids) {
     data.putLongAutoInc(id);
     }
     }
     data.setLen(data.getBufOffset());
     return post();
     }

     public boolean addRecord(long id) {
     return postById(id, LProtocol.JRQST_ADD_RECORD);
     }

     public boolean updateRecord(long id) {
     return postById(id, LProtocol.JRQST_UPDATE_RECORD);
     }

     public boolean deleteRecord(long id) {
     return postById(id, LProtocol.JRQST_DELETE_RECORD);
     }

     public boolean getSchedule(long id) {
     return postById(id, LProtocol.JRQST_GET_SCHEDULE);
     }

     public boolean addSchedule(long id) {
     return postById(id, LProtocol.JRQST_ADD_SCHEDULE);
     }

     public boolean updateSchedule(long id) {
     return postById(id, LProtocol.JRQST_UPDATE_SCHEDULE);
     }

     public boolean deleteSchedule(long id) {
     return postById(id, LProtocol.JRQST_DELETE_SCHEDULE);
     }

     public boolean addAccount(long id) {
     return postById(id, LProtocol.JRQST_ADD_ACCOUNT);
     }

     public boolean updateAccount(long id) {
     return postById(id, LProtocol.JRQST_UPDATE_ACCOUNT);
     }

     public boolean deleteAccount(long id) {
     return postById(id, LProtocol.JRQST_DELETE_ACCOUNT);
     }

     public boolean addCategory(long id) {
     return postById(id, LProtocol.JRQST_ADD_CATEGORY);
     }

     public boolean updateCategory(long id) {
     return postById(id, LProtocol.JRQST_UPDATE_CATEGORY);
     }

     public boolean deleteCategory(long id) {
     return postById(id, LProtocol.JRQST_DELETE_CATEGORY);
     }

     public boolean addTag(long id) {
     return postById(id, LProtocol.JRQST_ADD_TAG);
     }

     public boolean updateTag(long id) {
     return postById(id, LProtocol.JRQST_UPDATE_TAG);
     }

     public boolean deleteTag(long id) {
     return postById(id, LProtocol.JRQST_DELETE_TAG);
     }

     public boolean addVendor(long id) {
     return postById(id, LProtocol.JRQST_ADD_VENDOR);
     }

     public boolean updateVendor(long id) {
     return postById(id, LProtocol.JRQST_UPDATE_VENDOR);
     }

     public boolean deleteVendor(long id) {
     return postById(id, LProtocol.JRQST_DELETE_VENDOR);
     }

     public boolean addUserToAccount(long uid, long aid) {
     return postLongLong(uid, aid, LProtocol.JRQST_ADD_USER_TO_ACCOUNT);
     }

     public boolean removeUserFromAccount(long uid, long aid) {
     return postLongLong(uid, aid, LProtocol.JRQST_REMOVE_USER_FROM_ACCOUNT);
     }

     public boolean confirmAccountShare(long aid, long uid, boolean yes) {
     data.clear();
     data.putShortAutoInc(LProtocol.JRQST_CONFIRM_ACCOUNT_SHARE);
     data.putLongAutoInc(aid);
     data.putLongAutoInc(uid);
     data.putByteAutoInc((byte) (yes ? 1 : 0));
     data.setLen(data.getBufOffset());
     return post();
     }*/

    private func post() -> Bool {
        if LPreferences.getUserId().isEmpty {
            return false;
        }

        let aa = UnsafeMutableBufferPointer(start: data.getBuf(), count: data.getLen())
        let entry = LJournalEntry(journalId: Int(arc4random()), data: [UInt8](aa))
        let ret = DBJournal.instance.add(entry)
        if ret {
            postCount += 1
            LLog.d("\(self)", "total posted journal: \(postCount)")
            LBroadcast.post(LBroadcast.ACTION_NEW_JOURNAL_AVAILABLE)
        }
        return ret
    }

    private func post(jrqst: UInt16) -> Bool {
        data.clear()
        data.putShortAutoInc(jrqst);
        data.setLen(data.getOffset());
        return post()
    }

    private func postById(id: Int64, jrqst: UInt16) -> Bool {
        data.clear();
        data.putShortAutoInc(jrqst);
        data.putLongAutoInc(id);
        data.setLen(data.getOffset());
        return post();
    }

    private func postLongLong(_ long1: Int64, _ long2: Int64, jrqst: UInt16) -> Bool {
        data.clear();
        data.putShortAutoInc(jrqst);
        data.putLongAutoInc(long1);
        data.putLongAutoInc(long2);
        data.setLen(data.getOffset());
        return post();
    }
}
