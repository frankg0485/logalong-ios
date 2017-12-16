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

        func add(_ fetch: (LBuffer) -> D?, _ jdata: LBuffer, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            var remove = false;
            var new = false;
            let ret = true;
            let d = fetch(jdata)

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

        func update(_ fetch: (LBuffer) -> D?, _ jdata: LBuffer, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            var remove = false;
            var new = false;
            var ret = true;
            let d = fetch(jdata)

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

        func delete(_ fetch: (LBuffer) -> D?, _ jdata: LBuffer, _ ndata: LBuffer) -> (ret: Bool, new: Bool, remove: Bool) {
            var remove = false;
            var new = false;
            var ret = true;
            let d = fetch(jdata)

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
            super.init(id: account.id, gid: account.gid, name: account.name,
                       share: account.share,
                       showBalance: account.showBalance,
                       create: account.timestampCreate, access: account.timestampAccess)
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

        static func fetch(_ jdata: LBuffer) -> JLAccount? {
            if let account = DBAccount.instance.get(id: Int64(jdata.getLongAutoInc())) {
                return JLAccount(account: account)
            } else {
                return nil
            }
        }
    }

    private class JLCategory: LCategory, GenericJD {
        init(category: LCategory) {
            super.init(id: category.id, gid: category.gid, name: category.name,
                       create: category.timestampCreate, access: category.timestampAccess)
        }

        func getId() -> Int64 {
            return id
        }

        func getGid() -> Int64 {
            return gid
        }

        func getRequestCode() -> UInt16 {
            return LProtocol.JRQST_ADD_CATEGORY
        }

        func add_data(_ jdata: LBuffer) -> Bool {
            //data.putLongAutoInc(category.getPid());
            jdata.putLongAutoInc(0);
            let sname = [UInt8](name.utf8)
            jdata.putShortAutoInc(UInt16(sname.count))
            jdata.putBytesAutoInc(sname)
            jdata.setLen(jdata.getOffset());
            return true;
        }

        static func fetch(_ jdata: LBuffer) -> JLCategory? {
            if let category = DBCategory.instance.get(id: Int64(jdata.getLongAutoInc())) {
                return JLCategory(category: category)
            } else {
                return nil
            }
        }
    }

    private class JLTag: LTag, GenericJD {
        init(tag: LTag) {
            super.init(id: tag.id, gid: tag.gid, name: tag.name,
                       create: tag.timestampCreate, access: tag.timestampAccess)
        }

        func getId() -> Int64 {
            return id
        }

        func getGid() -> Int64 {
            return gid
        }

        func getRequestCode() -> UInt16 {
            return LProtocol.JRQST_ADD_TAG
        }

        func add_data(_ jdata: LBuffer) -> Bool {
            let sname = [UInt8](name.utf8)
            jdata.putShortAutoInc(UInt16(sname.count))
            jdata.putBytesAutoInc(sname)
            jdata.setLen(jdata.getOffset());
            return true;
        }

        static func fetch(_ jdata: LBuffer) -> JLTag? {
            if let tag = DBTag.instance.get(id: Int64(jdata.getLongAutoInc())) {
                return JLTag(tag: tag)
            } else {
                return nil
            }
        }
    }

    private class JLVendor: LVendor, GenericJD {
        init(vendor: LVendor) {
            super.init(id: vendor.id, gid: vendor.gid, name: vendor.name, type: vendor.type,
                       create: vendor.timestampCreate, access: vendor.timestampAccess)
        }

        func getId() -> Int64 {
            return id
        }

        func getGid() -> Int64 {
            return gid
        }

        func getRequestCode() -> UInt16 {
            return LProtocol.JRQST_ADD_VENDOR
        }

        func add_data(_ jdata: LBuffer) -> Bool {
            jdata.putByteAutoInc(type.rawValue);
            let sname = [UInt8](name.utf8)
            jdata.putShortAutoInc(UInt16(sname.count))
            jdata.putBytesAutoInc(sname)
            jdata.setLen(jdata.getOffset());
            return true;
        }

        static func fetch(_ jdata: LBuffer) -> JLVendor? {
            if let vendor = DBVendor.instance.get(id: Int64(jdata.getLongAutoInc())) {
                return JLVendor(vendor: vendor)
            } else {
                return nil
            }
        }
    }

    private var accountJournalFlushAction: GenericJournalFlushAction<JLAccount>?
    private var categoryJournalFlushAction: GenericJournalFlushAction<JLCategory>?
    private var tagJournalFlushAction: GenericJournalFlushAction<JLTag>?
    private var vendorJournalFlushAction: GenericJournalFlushAction<JLVendor>?

    func flush() -> Bool {
        /*
         if (recordJournalFlushAction == null) {
         recordJournalFlushAction = new LJournal.RecordJournalFlushAction();
         }
         if (scheduleJournalFlushAction == null) {
         scheduleJournalFlushAction = new LJournal.ScheduleJournalFlushAction();
         }*/
        if (accountJournalFlushAction == nil) {
            accountJournalFlushAction = GenericJournalFlushAction<JLAccount>()
        }
        if (categoryJournalFlushAction == nil) {
            categoryJournalFlushAction = GenericJournalFlushAction<JLCategory>()
        }
        if (tagJournalFlushAction == nil) {
            tagJournalFlushAction = GenericJournalFlushAction<JLTag>()
        }
        if (vendorJournalFlushAction == nil) {
            vendorJournalFlushAction = GenericJournalFlushAction<JLVendor>()
        }

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
            (retVal, newEntry, removeEntry) = accountJournalFlushAction!.add(JLAccount.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction!.update(JLAccount.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction!.delete(JLAccount.fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_CATEGORY:
            (retVal, newEntry, removeEntry) = categoryJournalFlushAction!.add(JLCategory.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_CATEGORY:
            (retVal, newEntry, removeEntry) = categoryJournalFlushAction!.update(JLCategory.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_CATEGORY:
            (retVal, newEntry, removeEntry) = categoryJournalFlushAction!.delete(JLCategory.fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_TAG:
            (retVal, newEntry, removeEntry) = tagJournalFlushAction!.add(JLTag.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_TAG:
            (retVal, newEntry, removeEntry) = tagJournalFlushAction!.update(JLTag.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_TAG:
            (retVal, newEntry, removeEntry) = tagJournalFlushAction!.delete(JLTag.fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_VENDOR:
            (retVal, newEntry, removeEntry) = vendorJournalFlushAction!.add(JLVendor.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_VENDOR:
            (retVal, newEntry, removeEntry) = vendorJournalFlushAction!.update(JLVendor.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_VENDOR:
            (retVal, newEntry, removeEntry) = vendorJournalFlushAction!.delete(JLVendor.fetch, jdata, ndata)
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

    func getAllAccounts() -> Bool {
        return post(LProtocol.JRQST_GET_ACCOUNTS);
    }

    func getAllCategories() -> Bool {
        return post(LProtocol.JRQST_GET_CATEGORIES);
    }

    func getAllTags() -> Bool {
        return post(LProtocol.JRQST_GET_TAGS);
    }

    func getAllVendors() -> Bool {
        return post(LProtocol.JRQST_GET_VENDORS);
    }

    func getAllRecords() -> Bool {
        //return post(LProtocol.JRQST_GET_RECORDS);
        return getRecords(nil);
    }

    func getAllSchedules() -> Bool {
        return post(LProtocol.JRQST_GET_SCHEDULES);
    }

    func getAccountRecords(_ aid: Int64) -> Bool {
        return postById(aid, LProtocol.JRQST_GET_ACCOUNT_RECORDS);
    }

    func getAccountSchedules(_ aid: Int64) -> Bool {
        return postById(aid, LProtocol.JRQST_GET_ACCOUNT_SCHEDULES);
    }

    func getAccountUsers(_ aid: Int64) -> Bool {
        return postById(aid, LProtocol.JRQST_GET_ACCOUNT_USERS);
    }

    func getRecord(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_GET_RECORD);
    }

    func getRecords(_ ids: [Int64]? ) -> Bool {
        data.clear();
        data.putShortAutoInc(LProtocol.JRQST_GET_RECORDS);
        if (nil == ids) {
            data.putShortAutoInc(UInt16(0)); // get all records;
        } else {
            data.putShortAutoInc(UInt16(ids!.count));
            for id in ids! {
                data.putLongAutoInc(id);
            }
        }
        data.setLen(data.getOffset());
        return post();
    }

    func addRecord(id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_RECORD);
    }

    func updateRecord(id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_RECORD);
    }

    func deleteRecord(id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_DELETE_RECORD);
    }

    func getSchedule(id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_GET_SCHEDULE);
    }

    func addSchedule(id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_SCHEDULE);
    }

    func updateSchedule(id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_SCHEDULE);
    }

    func deleteSchedule(id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_DELETE_SCHEDULE);
    }

    func addAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_ACCOUNT);
    }

    func updateAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_ACCOUNT);
    }

    func deleteAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_DELETE_ACCOUNT);
    }

    func addCategory(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_CATEGORY);
    }

    func updateCategory(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_CATEGORY);
    }

    func deleteCategory(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_DELETE_CATEGORY);
    }

    func addTag(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_TAG);
    }

    func updateTag(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_TAG);
    }

    func deleteTag(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_DELETE_TAG);
    }

    func addVendor(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_VENDOR);
    }

    func updateVendor(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_VENDOR);
    }

    func deleteVendor(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_DELETE_VENDOR);
    }

    func addUserToAccount(uid: Int64,  aid: Int64) -> Bool {
        return postLongLong(uid, aid, LProtocol.JRQST_ADD_USER_TO_ACCOUNT);
    }

    func removeUserFromAccount(uid: Int64, aid: Int64) -> Bool {
        return postLongLong(uid, aid, LProtocol.JRQST_REMOVE_USER_FROM_ACCOUNT);
    }

    func confirmAccountShare(aid: Int64, uid: Int64, yes: Bool) -> Bool {
        data.clear();
        data.putShortAutoInc(LProtocol.JRQST_CONFIRM_ACCOUNT_SHARE);
        data.putLongAutoInc(aid);
        data.putLongAutoInc(uid);
        data.putByteAutoInc(UInt8(yes ? 1 : 0));
        data.setLen(data.getOffset());
        return post();
    }

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
