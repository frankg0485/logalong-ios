//
//  LJournal.swift
//  LogAlong
//
//  Created by Michael Gao on 11/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import Foundation

protocol GenericJD {
    func getId() -> Int64
    func getGid() -> Int64
    func getRequestCode() -> UInt16
    func add_data(_ jdata: LBuffer) -> Bool
}

class LJournal {
    static let MAX_ERROR_RETRIES = 10
    static let MAX_JOURNAL_LENGTH = 512
    static let instance = LJournal()

    var journalId: Int = 0
    var data = LBuffer(size: LJournal.MAX_JOURNAL_LENGTH)

    private var lastFlushMs: Int64 = 0
    private var lastFlushId: Int = 0
    private var postCount = 0;
    private var flushCount = 0;

    private var removeEntry = false
    private var newEntry = false
    private var errorCount = 0

    private class GenericJournalFlushAction<D: GenericJD> {
        private func do_add(_ jdata: LBuffer, _ d: D) -> Bool {
            jdata.clear();
            jdata.putShortAutoInc(d.getRequestCode())
            jdata.putLongAutoInc(d.getId())
            return d.add_data(jdata)
        }

        private func do_update(_ jdata: LBuffer, _ d : D) -> Bool {
            jdata.clear();
            jdata.putShortAutoInc(UInt16(d.getRequestCode() + 1));
            jdata.putLongAutoInc(d.getGid())
            return d.add_data(jdata)
        }

        private func do_delete(_ jdata: LBuffer, _ d: D) {
            jdata.clear();
            jdata.putShortAutoInc(UInt16(d.getRequestCode() + 2))
            jdata.putLongAutoInc(d.getGid());
            jdata.setLen(jdata.getOffset());
        }

        func add(_ d: D?, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            var remove = false;
            var new = false;
            let ret = true;

            if (d == nil) {
                //ok to ignore add request if entry has been deleted afterwards
                LLog.w("\(self)", "unable to find requested db entry");
                remove = true;
            } else if (d!.getGid() != 0) {
                // ok to ignore add request if entry has GID assigned already
                remove = true;
            } else {
                if (!do_add(ndata, d!)) {
                    LLog.w("\(self)", "unable to add db entry");
                    remove = true;
                } else {
                    new = true;
                }
            }
            return (ret, new, remove)
        }

        func update(_ d: D?, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            var remove = false;
            var new = false;
            var ret = true;

            if (d == nil) {
                //ok to ignore update request if entry has been deleted afterwards
                LLog.w("\(self)", "unable to find entry");
                remove = true;
            } else {
                if (d!.getGid() == 0) {
                    ret = false;
                } else {
                    do_update(ndata, d!);
                    new = true;
                }
            }
            return (ret, new, remove)
        }

        func delete(_ d: D?, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            var remove = false;
            var new = false;
            var ret = true;

            if (d == nil) {
                //ok to ignore delete request if entry has been deleted already
                LLog.w("\(self)", "unable to find db entry")
                remove = true;
            } else {
                if (d!.getGid() == 0) {
                    ret = false;
                } else {
                    do_delete(ndata, d!);
                    new = true;
                }
            }
            return (ret, new, remove)
        }

    }

    private class JLAccount: LAccount, GenericJD {
        init(account: LAccount) {
            super.init(id: account.id, gid: account.gid, name: account.name)
        }

        func getId() -> Int64 {
            return id
        }

        func getGid() -> Int64 {
            return gid
        }

        func getRequestCode() -> UInt16 {
            return LProtocol.JRQST_ADD_ACCOUNT
        }

        func add_data(_ jdata: LBuffer) -> Bool {
            let sname = [UInt8](name.utf8)
            jdata.putShortAutoInc(UInt16(sname.count))
            jdata.putBytesAutoInc(sname)
            jdata.setLen(jdata.getOffset());
            return true;
        }
    }

    private class AccountJournalFlushAction : GenericJournalFlushAction<JLAccount> {
        private func getD(_ jdata: LBuffer) -> JLAccount? {
            if let account = DBAccount.instance.get(id: Int64(jdata.getLongAutoInc())) {
                return JLAccount(account: account)
            } else {
                return nil
            }
        }

        func add(_ jdata: LBuffer, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            return super.add(getD(jdata), ndata)
        }

        func update(_ jdata: LBuffer, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            return super.update(getD(jdata), ndata)
        }

        func delete(_ jdata: LBuffer, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            return super.delete(getD(jdata), ndata)
        }
    }

    private var accountJournalFlushAction: AccountJournalFlushAction?

    func flush() -> Bool {
        /*
        if (recordJournalFlushAction == null) {
            recordJournalFlushAction = new LJournal.RecordJournalFlushAction();
        }
        if (scheduleJournalFlushAction == null) {
            scheduleJournalFlushAction = new LJournal.ScheduleJournalFlushAction();
        }*/
        if (accountJournalFlushAction == nil) {
            accountJournalFlushAction = AccountJournalFlushAction();
        }
        /*
        if (categoryJournalFlushAction == null) {
            categoryJournalFlushAction = new LJournal.CategoryJournalFlushAction();
        }
        if (tagJournalFlushAction == null) {
            tagJournalFlushAction = new LJournal.TagJournalFlushAction();
        }
        if (vendorJournalFlushAction == null) {
            vendorJournalFlushAction = new LJournal.VendorJournalFlushAction();
        }*/

        let entry = DBJournal.instance.get()
        if (nil == entry) {
            return false
        }

        if (lastFlushId == entry?.journalId && (Date().currentTimeMillis - lastFlushMs < 15000)) {
            //so not to keep flushing the same journal over and over
            LLog.w("\(self)", "journal flush request ignored: \(entry!.journalId)")
            LLog.d("\(self)", "lastFlushMs: \(lastFlushMs) delta: \(lastFlushMs - Date().currentTimeMillis)")
            return false;
        }
        LLog.d("\(self)", "total flushing count: \(flushCount)")
        flushCount += 1

        var retVal = true
        var removeEntry = false
        var newEntry = false

        lastFlushId = entry!.journalId;
        lastFlushMs = Date().currentTimeMillis;

        let jdata: LBuffer = LBuffer(buf: entry!.data);
        let ndata: LBuffer = LBuffer(size: LJournal.MAX_JOURNAL_LENGTH);
        switch (jdata.getShortAutoInc()) {
            /*
        case LProtocol.JRQST_ADD_RECORD:
            if (!recordJournalFlushAction.add(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_UPDATE_RECORD:
            if (!recordJournalFlushAction.update(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_DELETE_RECORD:
            if (!recordJournalFlushAction.delete(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_ADD_SCHEDULE:
            if (!scheduleJournalFlushAction.add(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_UPDATE_SCHEDULE:
            if (!scheduleJournalFlushAction.update(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_DELETE_SCHEDULE:
            if (!scheduleJournalFlushAction.delete(jdata, ndata)) return false;
            break;
             */
        case LProtocol.JRQST_ADD_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction!.add(jdata, ndata)
        case LProtocol.JRQST_UPDATE_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction!.update(jdata, ndata)
        case LProtocol.JRQST_DELETE_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction!.delete(jdata, ndata)
            /*
        case LProtocol.JRQST_ADD_CATEGORY:
            if (!categoryJournalFlushAction.add(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_UPDATE_CATEGORY:
            if (!categoryJournalFlushAction.update(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_DELETE_CATEGORY:
            if (!categoryJournalFlushAction.delete(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_ADD_TAG:
            if (!tagJournalFlushAction.add(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_UPDATE_TAG:
            if (!tagJournalFlushAction.update(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_DELETE_TAG:
            if (!tagJournalFlushAction.delete(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_ADD_VENDOR:
            if (!vendorJournalFlushAction.add(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_UPDATE_VENDOR:
            if (!vendorJournalFlushAction.update(jdata, ndata)) return false;
            break;
        case LProtocol.JRQST_DELETE_VENDOR:
            if (!vendorJournalFlushAction.delete(jdata, ndata)) return false;
            break;
             */
        default:
            break
        }

        if (!retVal) {
            // let service to retry later
            errorCount += 1
            if (errorCount > LJournal.MAX_ERROR_RETRIES) {
                removeEntry = true;
                LLog.e("\(self)", "db entry gid not available, journal request dropped");
            } else {
                return false;
            }
        }

        errorCount = 0;
        if (removeEntry) {
            DBJournal.instance.remove(id: entry!.journalId)
            return false;
        }

        if (newEntry) {
            let entry2 = LJournalEntry(journalId: entry!.journalId, datap: ndata.getBuf(), bytes: ndata.getLen())
            UiRequest.instance.UiPostJournal(entry!.journalId, data: entry2.data)
        } else {
            UiRequest.instance.UiPostJournal(entry!.journalId, data: entry!.data);
        }
        return true;
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
     }*/

    func addAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_ACCOUNT);
    }

    func updateAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_ACCOUNT);
    }

    func deleteAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_DELETE_ACCOUNT);
    }

    /*
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

    private func post(_ jrqst: UInt16) -> Bool {
        data.clear()
        data.putShortAutoInc(jrqst);
        data.setLen(data.getOffset());
        return post()
    }

    private func postById(_ id: Int64, _ jrqst: UInt16) -> Bool {
        data.clear();
        data.putShortAutoInc(jrqst);
        data.putLongAutoInc(id);
        data.setLen(data.getOffset());
        return post();
    }

    private func postLongLong(_ long1: Int64, _ long2: Int64, _ jrqst: UInt16) -> Bool {
        data.clear();
        data.putShortAutoInc(jrqst);
        data.putLongAutoInc(long1);
        data.putLongAutoInc(long2);
        data.setLen(data.getOffset());
        return post();
    }
}
