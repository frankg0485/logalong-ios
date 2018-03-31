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

    class JLTransaction : LTransactionDetails, GenericJD {
        init(details: LTransactionDetails) {
            super.init(id: details.id, gid: details.gid, rid: details.rid,
                       accountId: details.accountId, accountId2: details.accountId2, amount: details.amount,
                       type: details.type, categoryId: details.categoryId,
                       tagId: details.tagId, vendorId: details.vendorId, note: details.note, by: details.by,
                       timestamp: details.timestamp, create: details.timestampCreate,
                       access: details.timestampAccess, account: details.account, account2: details.account2,
                       category: details.category, tag: details.tag, vendor: details.vendor)
        }

        func getId() -> Int64 {
            return id
        }

        func getGid() -> Int64 {
            return gid
        }

        func getRequestCode() -> UInt16 {
            return LProtocol.JRQST_ADD_RECORD
        }

        func add_data(_ jdata: LBuffer) -> Bool {
            if (TransactionType.TRANSFER_COPY == type) {
                return false
            }

            jdata.putLongAutoInc(account.gid)
            jdata.putLongAutoInc(account2.gid)
            jdata.putLongAutoInc(category.gid)
            jdata.putLongAutoInc(tag.gid)
            jdata.putLongAutoInc(vendor.gid)
            jdata.putByteAutoInc(type.rawValue)
            jdata.putDoubleAutoInc(amount)
            jdata.putLongAutoInc(by)
            if (0 == rid) {
                rid = LTransaction.generateRid()
                _ = DBTransaction.instance.updateColumnById(id, DBHelper.rid, rid)
                if (TransactionType.TRANSFER == type) {
                    _ = DBTransaction.instance.updateTransferCopyRid(transaction: self)
                }
            }
            jdata.putLongAutoInc(rid)
            jdata.putLongAutoInc(timestamp)
            jdata.putLongAutoInc(timestampCreate)
            jdata.putLongAutoInc(timestampAccess)

            let snote = [UInt8](note.utf8)
            jdata.putShortAutoInc(UInt16(snote.count))
            jdata.putBytesAutoInc(snote)
            jdata.setLen(jdata.getOffset())

            return true
        }

        static func fetch(_ jdata: LBuffer) -> JLTransaction? {
            if let details = DBTransaction.instance.getDetails(id: jdata.getLongAutoInc()) {
                return JLTransaction(details: details)
            } else {
                return nil
            }
        }
        static func fake_fetch(_ jdata: LBuffer) -> JLTransaction? {
            let details = LTransactionDetails()
            details.gid = jdata.getLongAutoInc()
            return JLTransaction(details: details)
        }
    }

    private class JLScheduledTransaction : LScheduledTransaction, GenericJD {
        func getId() -> Int64 {
            return id
        }

        func getGid() -> Int64 {
            return gid
        }

        func getRequestCode() -> UInt16 {
            return LProtocol.JRQST_ADD_SCHEDULE
        }

        func add_data(_ jdata: LBuffer) -> Bool {
            if (TransactionType.TRANSFER_COPY == type) {
                return false
            }

            if let account = DBAccount.instance.get(id: accountId) {
                jdata.putLongAutoInc(account.gid)
            } else {
                jdata.putLongAutoInc(0)
            }

            if let account2 = DBAccount.instance.get(id: accountId2) {
                jdata.putLongAutoInc(account2.gid)
            } else {
                jdata.putLongAutoInc(0)
            }

            if let category = DBCategory.instance.get(id: categoryId) {
                jdata.putLongAutoInc(category.gid)
            } else {
                jdata.putLongAutoInc(0)
            }

            if let tag = DBTag.instance.get(id: tagId) {
                jdata.putLongAutoInc(tag.gid)
            } else {
                jdata.putLongAutoInc(0)
            }

            if let vendor = DBVendor.instance.get(id: vendorId) {
                jdata.putLongAutoInc(vendor.gid)
            } else {
                jdata.putLongAutoInc(0)
            }

            jdata.putByteAutoInc(type.rawValue)
            jdata.putDoubleAutoInc(amount)
            jdata.putLongAutoInc(by)
            jdata.putLongAutoInc(rid)
            jdata.putLongAutoInc(timestamp)
            jdata.putLongAutoInc(timestampCreate)
            jdata.putLongAutoInc(timestampAccess)

            let snote = [UInt8](note.utf8)
            jdata.putShortAutoInc(UInt16(snote.count))
            jdata.putBytesAutoInc(snote)

            jdata.putLongAutoInc(scheduleTime)
            jdata.putByteAutoInc(UInt8(repeatInterval))
            jdata.putByteAutoInc(UInt8(repeatUnit))
            jdata.putByteAutoInc(UInt8(repeatCount))
            jdata.putByteAutoInc(UInt8(enabled ? 1 : 0))

            jdata.setLen(jdata.getOffset())

            return true
        }

        static func fetch(_ jdata: LBuffer) -> JLScheduledTransaction? {
            if let schedule = DBScheduledTransaction.instance.get(id: jdata.getLongAutoInc()) {
                return JLScheduledTransaction(schedule: schedule)
            } else {
                return nil
            }
        }
        static func fake_fetch(_ jdata: LBuffer) -> JLScheduledTransaction? {
            let schedule = LScheduledTransaction()
            schedule.gid = jdata.getLongAutoInc()
            return JLScheduledTransaction(schedule: schedule)
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
            if let account = DBAccount.instance.get(id: jdata.getLongAutoInc()) {
                return JLAccount(account: account)
            } else {
                return nil
            }
        }
        static func fake_fetch(_ jdata: LBuffer) -> JLAccount? {
            let account = LAccount()
            account.gid = jdata.getLongAutoInc()
            return JLAccount(account: account)
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
            if let category = DBCategory.instance.get(id: jdata.getLongAutoInc()) {
                return JLCategory(category: category)
            } else {
                return nil
            }
        }
        static func fake_fetch(_ jdata: LBuffer) -> JLCategory? {
            let category = LCategory()
            category.gid = jdata.getLongAutoInc()
            return JLCategory(category: category)
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
            if let tag = DBTag.instance.get(id: jdata.getLongAutoInc()) {
                return JLTag(tag: tag)
            } else {
                return nil
            }
        }
        static func fake_fetch(_ jdata: LBuffer) -> JLTag? {
            let tag = LTag()
            tag.gid = jdata.getLongAutoInc()
            return JLTag(tag: tag)
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
            if let vendor = DBVendor.instance.get(id: jdata.getLongAutoInc()) {
                return JLVendor(vendor: vendor)
            } else {
                return nil
            }
        }
        static func fake_fetch(_ jdata: LBuffer) -> JLVendor? {
            let vendor = LVendor()
            vendor.gid = jdata.getLongAutoInc()
            return JLVendor(vendor: vendor)
        }
    }

    private lazy var accountJournalFlushAction: GenericJournalFlushAction<JLAccount> = GenericJournalFlushAction<JLAccount>()
    private lazy var categoryJournalFlushAction: GenericJournalFlushAction<JLCategory> = GenericJournalFlushAction<JLCategory>()
    private lazy var tagJournalFlushAction: GenericJournalFlushAction<JLTag> = GenericJournalFlushAction<JLTag>()
    private lazy var vendorJournalFlushAction: GenericJournalFlushAction<JLVendor> = GenericJournalFlushAction<JLVendor>()
    private lazy var recordJournalFlushAction: GenericJournalFlushAction<JLTransaction> = GenericJournalFlushAction<JLTransaction>()
    private lazy var scheduleJournalFlushAction: GenericJournalFlushAction<JLScheduledTransaction> = GenericJournalFlushAction<JLScheduledTransaction>()

    func flush() -> Bool {

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
        case LProtocol.JRQST_ADD_RECORD:
            (retVal, newEntry, removeEntry) = recordJournalFlushAction.add(JLTransaction.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_RECORD:
            (retVal, newEntry, removeEntry) = recordJournalFlushAction.update(JLTransaction.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_RECORD:
            (retVal, newEntry, removeEntry) = recordJournalFlushAction.delete(JLTransaction.fake_fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_SCHEDULE:
            (retVal, newEntry, removeEntry) = scheduleJournalFlushAction.add(JLScheduledTransaction.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_SCHEDULE:
            (retVal, newEntry, removeEntry) = scheduleJournalFlushAction.update(JLScheduledTransaction.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_SCHEDULE:
            (retVal, newEntry, removeEntry) = scheduleJournalFlushAction.delete(JLScheduledTransaction.fake_fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction.add(JLAccount.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction.update(JLAccount.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_ACCOUNT:
            (retVal, newEntry, removeEntry) = accountJournalFlushAction.delete(JLAccount.fake_fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_CATEGORY:
            (retVal, newEntry, removeEntry) = categoryJournalFlushAction.add(JLCategory.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_CATEGORY:
            (retVal, newEntry, removeEntry) = categoryJournalFlushAction.update(JLCategory.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_CATEGORY:
            (retVal, newEntry, removeEntry) = categoryJournalFlushAction.delete(JLCategory.fake_fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_TAG:
            (retVal, newEntry, removeEntry) = tagJournalFlushAction.add(JLTag.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_TAG:
            (retVal, newEntry, removeEntry) = tagJournalFlushAction.update(JLTag.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_TAG:
            (retVal, newEntry, removeEntry) = tagJournalFlushAction.delete(JLTag.fake_fetch, jdata, ndata)
        case LProtocol.JRQST_ADD_VENDOR:
            (retVal, newEntry, removeEntry) = vendorJournalFlushAction.add(JLVendor.fetch, jdata, ndata)
        case LProtocol.JRQST_UPDATE_VENDOR:
            (retVal, newEntry, removeEntry) = vendorJournalFlushAction.update(JLVendor.fetch, jdata, ndata)
        case LProtocol.JRQST_DELETE_VENDOR:
            (retVal, newEntry, removeEntry) = vendorJournalFlushAction.delete(JLVendor.fake_fetch, jdata, ndata)
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

    func addRecord(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_RECORD);
    }

    func updateRecord(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_RECORD);
    }

    func deleteRecord(gid: Int64) -> Bool {
        return postById(gid, LProtocol.JRQST_DELETE_RECORD);
    }

    func getSchedule(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_GET_SCHEDULE);
    }

    func addSchedule(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_SCHEDULE);
    }

    func updateSchedule(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_SCHEDULE);
    }

    func deleteSchedule(gid: Int64) -> Bool {
        return postById(gid, LProtocol.JRQST_DELETE_SCHEDULE);
    }

    func addAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_ACCOUNT);
    }

    func updateAccount(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_ACCOUNT);
    }

    func deleteAccount(gid: Int64) -> Bool {
        return postById(gid, LProtocol.JRQST_DELETE_ACCOUNT);
    }

    func addCategory(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_CATEGORY);
    }

    func updateCategory(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_CATEGORY);
    }

    func deleteCategory(gid: Int64) -> Bool {
        return postById(gid, LProtocol.JRQST_DELETE_CATEGORY);
    }

    func addTag(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_TAG);
    }

    func updateTag(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_TAG);
    }

    func deleteTag(gid: Int64) -> Bool {
        return postById(gid, LProtocol.JRQST_DELETE_TAG);
    }

    func addVendor(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_ADD_VENDOR);
    }

    func updateVendor(_ id: Int64) -> Bool {
        return postById(id, LProtocol.JRQST_UPDATE_VENDOR);
    }

    func deleteVendor(gid: Int64) -> Bool {
        return postById(gid, LProtocol.JRQST_DELETE_VENDOR);
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
