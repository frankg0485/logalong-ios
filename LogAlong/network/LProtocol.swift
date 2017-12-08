//
//  LProtocol.swift
//  LogAlong
//
//  Created by Michael Gao on 11/14/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

enum LConnectionState {
    case DISCONNECTED
    case CONNECTED
    case LOGGED_IN
}

final class LProtocol : LServerDelegate {
    static let instance = LProtocol()

    static let PACKET_MAX_PAYLOAD_LEN = 1456;
    static let PACKET_MAX_LEN = (PACKET_MAX_PAYLOAD_LEN + 8);
    static let PACKET_MIN_LEN = 12; //minimum packet length 8 + CRC32
    static let PACKET_SIGNATURE1 : UInt16 = 0xffaa;

    static let PAYLOAD_DIRECTION_RQST : UInt16 = 0;
    static let PAYLOAD_DIRECTION_RSPS : UInt16 = 0x8000;

    static let PAYLOAD_TYPE_MASK : UInt16 = 0x1800;
    static let PAYLOAD_TYPE_SHIFT : UInt16 = 11;
    static let PAYLOAD_VALUE_MASK : UInt16 = 0x07ff;

    static let PLAYLOAD_TYPE_SYS : UInt16 = (2 << PAYLOAD_TYPE_SHIFT);
    static let PLAYLOAD_TYPE_USER : UInt16 = (3 << PAYLOAD_TYPE_SHIFT);

    static let RESPONSE_PARSE_RESULT_DONE = 10;
    static let RESPONSE_PARSE_RESULT_MORE2COME = 20;
    static let RESPONSE_PARSE_RESULT_ERROR = 99;

    static let PUSH_NOTIFICATION : UInt16 = 0x0bad

    static func PACKET_PAYLOAD_LENGTH(_ payloadLen: Int) -> Int {
        return ((((payloadLen) + 3) / 4) * 4);
    }

    static let RQST_SYS : UInt16 = PLAYLOAD_TYPE_SYS | PAYLOAD_DIRECTION_RQST;
    static let RQST_USER : UInt16 = PLAYLOAD_TYPE_USER | PAYLOAD_DIRECTION_RQST;
    static let RSPS : UInt16 = PAYLOAD_DIRECTION_RSPS;

    static let RSPS_OK : UInt16 = 0x0010;
    static let RSPS_MORE : UInt16 = 0x005a;
    static let RSPS_USER_NOT_FOUND : UInt16 = 0xf000;
    static let RSPS_WRONG_PASSWORD : UInt16 = 0xf001;
    static let RSPS_ACCOUNT_NOT_FOUND : UInt16 = 0xf010;
    static let RSPS_ERROR : UInt16 = 0xffff;

    static let RQST_SCRAMBLER_SEED : UInt16 = RQST_SYS | 0x100;
    static let RQST_GET_USER_BY_NAME : UInt16 = RQST_SYS | 0x200;
    static let RQST_CREATE_USER : UInt16 = RQST_SYS | 0x204;
    static let RQST_SIGN_IN : UInt16 = RQST_SYS | 0x208;
    static let RQST_LOG_IN : UInt16 = RQST_SYS | 0x209;
    static let RQST_RESET_PASSWORD : UInt16 = RQST_SYS | 0x20a;
    static let RQST_UPDATE_USER_PROFILE : UInt16 = RQST_SYS | 0x20c;

    static let JRQST_ADD_ACCOUNT : UInt16 = 0x001;
    static let JRQST_UPDATE_ACCOUNT : UInt16 = 0x002;
    static let JRQST_DELETE_ACCOUNT : UInt16 = 0x003;

    static let JRQST_ADD_CATEGORY : UInt16 = 0x011;
    static let JRQST_UPDATE_CATEGORY : UInt16 = 0x012;
    static let JRQST_DELETE_CATEGORY : UInt16 = 0x013;

    static let JRQST_ADD_TAG : UInt16 = 0x021;
    static let JRQST_UPDATE_TAG : UInt16 = 0x022;
    static let JRQST_DELETE_TAG : UInt16 = 0x023;

    static let JRQST_ADD_VENDOR : UInt16 = 0x031;
    static let JRQST_UPDATE_VENDOR : UInt16 = 0x032;
    static let JRQST_DELETE_VENDOR : UInt16 = 0x033;

    static let JRQST_ADD_RECORD : UInt16 = 0x041;
    static let JRQST_UPDATE_RECORD : UInt16 = 0x042;
    static let JRQST_DELETE_RECORD : UInt16 = 0x043;

    static let JRQST_ADD_SCHEDULE : UInt16 = 0x051;
    static let JRQST_UPDATE_SCHEDULE : UInt16 = 0x052;
    static let JRQST_DELETE_SCHEDULE : UInt16 = 0x053;

    static let JRQST_GET_ACCOUNTS : UInt16 = 0x101;
    static let JRQST_GET_CATEGORIES : UInt16 = 0x111;
    static let JRQST_GET_TAGS : UInt16 = 0x121;
    static let JRQST_GET_VENDORS : UInt16 = 0x131;
    static let JRQST_GET_RECORD : UInt16 = 0x141;
    static let JRQST_GET_RECORDS : UInt16 = 0x142;
    static let JRQST_GET_ACCOUNT_RECORDS : UInt16 = 0x143;
    static let JRQST_GET_ACCOUNT_USERS : UInt16 = 0x151;
    static let JRQST_GET_SCHEDULE : UInt16 = 0x161
    static let JRQST_GET_SCHEDULES : UInt16 = 0x162;
    static let JRQST_GET_ACCOUNT_SCHEDULES : UInt16 = 0x163;

    static let JRQST_ADD_USER_TO_ACCOUNT : UInt16 = 0x301;
    static let JRQST_REMOVE_USER_FROM_ACCOUNT : UInt16 = 0x302;
    static let JRQST_CONFIRM_ACCOUNT_SHARE : UInt16 = 0x303;

    static let RQST_POST_JOURNAL : UInt16 = RQST_SYS | 0x555;
    static let RQST_POLL : UInt16 = RQST_SYS | 0x777;
    static let RQST_POLL_ACK : UInt16 = RQST_SYS | 0x778;
    static let RQST_UTC_SYNC : UInt16 = RQST_SYS | 0x7f0;
    static let RQST_PING : UInt16 = RQST_SYS | 0x7ff;

    var pktBuf = LBuffer(size: 0)
    var scrambler: UInt32 = 0;
    var state = LConnectionState.DISCONNECTED;

    func genScrambler() -> UInt32 {
        var ss : UInt32 = 0;
        var ii : Int = 0;
        while (ii < 4) {
            let ch = arc4random_uniform(93) + 30
            if ((ch > 90 && ch < 97) || (ch > 39 && ch < 41) ) {
                continue;
            }
            ii += 1;
            ss <<= 8;
            ss += ch;
        }
        return ss;
    }

    func start() {
        scrambler = genScrambler();
        let version : UInt16 = 1; //TODO: get app version on the fly
        let iosId : UInt16 = 2;
        LTransport.send_rqst(LProtocol.RQST_SCRAMBLER_SEED, d32: scrambler,
                             d161: version, d162: iosId, scrambler: 0);
    }

    //-1: error, 1: success, 0: partial packet
    func consumePacket(_ pkt: LBuffer) -> Int {
        if (pkt.getLen() - pkt.getOffset() < LProtocol.PACKET_MIN_LEN) {
            return 0;
        }

        //Intent rspsIntent;
        let origOffset = pkt.getOffset();
        let total = (pkt.getShortAt(origOffset + 2) & 0xfff) + 4; //mask out sequence bits
        let rsps = pkt.getShortAt(origOffset + 4);

        //partial packet received, ignore and wait for more data to come
        if (total > pkt.getLen() - pkt.getOffset()) {
            return 0;
        }

        //verify CRC32
        let crc = crc32(0, buffer: pkt.getBuf() + pkt.getOffset(), length: Int(total - 4))
        if (crc != pkt.getIntAt(pkt.getOffset() + Int(total - 4))) {
            LLog.w("\(self)", "drop corrupted packet: checksum mismatch");
            pkt.setOffset(pkt.getOffset() + Int(total)); //discard packet
            return 1;
        }

        LTransport.scramble(pkt, scrambler);
        pkt.skip(6);
        let status = pkt.getShortAutoInc();

        //if ((RSPS | requestCode) != rsps) {
        //    LLog.w("\(self)", "protocol failed: unexpected response");
        //    packetConsumptionStatus.bytesConsumed = -1;
        //    return packetConsumptionStatus;
        //}

        //if (status != LProtocol.RSPS_OK && status != LProtocol.RSPS_MORE) {
        //    LLog.w("\(self)", "protocol request code: " + requestCode + " error status := " + status);
        //}

        // 'state' is updated only this thread, hence safe to read without lock
        var bdata = [String:Any]();
        bdata["status"] = Int(status);

        switch (state) {
        case LConnectionState.DISCONNECTED:
            switch (rsps) {
            case LProtocol.RSPS | LProtocol.RQST_SCRAMBLER_SEED:
                let serverVersion = pkt.getShort();
                LLog.d("\(self)", "channel scrambler seed sent, server version: \(serverVersion)");
                state = LConnectionState.CONNECTED;

                LBroadcast.post(LBroadcast.ACTION_NETWORK_CONNECTED);
                break;

            default:
                //LLog.w("\(self)", "unexpected response: " + rsps + "@state: " + state);
                break;
            }
            break;

        case LConnectionState.CONNECTED:
            switch (rsps) {
            case LProtocol.RSPS | LProtocol.RQST_GET_USER_BY_NAME:
                /*
                 rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
                 .ACTION_GET_USER_BY_NAME));
                 rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);

                 if (RSPS_OK == status) {
                 var name: String = ""
                 var fullName: String = ""
                 var gid: UInt64 = pkt.getLongAutoInc()
                 var bytes: UInt16 = pkt.getShortAutoInc()
                 name = pkt.getStringAutoInc(bytes)
                 bytes = pkt.getShortAutoInc()
                 fullName = pkt.getStringAutoInc(bytes)

                 rspsIntent.putExtra("id", gid);
                 rspsIntent.putExtra("name", name);
                 rspsIntent.putExtra("fullName", fullName);
                 }
                 LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);
                 */
                break;

            case LProtocol.RSPS | LProtocol.RQST_CREATE_USER:
                LBroadcast.post(LBroadcast.ACTION_CREATE_USER, sender: nil, data: bdata)
                break;

            case LProtocol.RSPS | LProtocol.RQST_SIGN_IN:
                if (LProtocol.RSPS_OK == status) {
                    LPreferences.setLoginError(false)
                    let bytes = pkt.getShortAutoInc()
                    let name = pkt.getStringAutoInc(Int(bytes))

                    bdata["userName"] = name
                }

                LBroadcast.post(LBroadcast.ACTION_SIGN_IN, sender: nil, data: bdata)
                break;

            case LProtocol.RSPS | LProtocol.RQST_LOG_IN:
                if (LProtocol.RSPS_OK == status) {
                    LPreferences.setLoginError(false);
                    LPreferences.setUserIdNum(Int(pkt.getLongAutoInc()));
                    LPreferences.setUserLoginNum(Int(pkt.getLongAutoInc()));

                    state = LConnectionState.LOGGED_IN;
                } else {
                    //login error, remember to force user to login
                    LPreferences.setLoginError(true);
                }

                LBroadcast.post(LBroadcast.ACTION_LOG_IN, sender: nil, data: bdata)
                break;

            case LProtocol.RSPS | LProtocol.RQST_RESET_PASSWORD:
                /*
                 rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver.ACTION_UI_RESET_PASSWORD));
                 rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);
                 LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);
                 */
                break;

            default:
                LLog.w("\(self)", "unexpected response: \(rsps) @state: \(state)");
                break;
            }

        case LConnectionState.LOGGED_IN:
            LLog.d("\(self)", "user logged in")
            switch (rsps) {
            case LProtocol.RSPS | LProtocol.RQST_UPDATE_USER_PROFILE:
                /*rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
                    .ACTION_UPDATE_USER_PROFILE));
                rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);
                LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);*/

                LBroadcast.post(LBroadcast.ACTION_UPDATE_USER_PROFILE, sender: nil, data: bdata)
                break;

            case LProtocol.RSPS | LProtocol.RQST_SIGN_IN:
                /*rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
                    .ACTION_SIGN_IN));
                rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);
                if (RSPS_OK == status) {
                    LPreferences.setLoginError(false);
                    int bytes = pkt.getShortAutoInc();
                    String name = pkt.getStringAutoInc(bytes);
                    rspsIntent.putExtra("userName", name);
                }
                LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);*/
                break;

            case LProtocol.RSPS | LProtocol.RQST_GET_USER_BY_NAME:
                /*rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
                    .ACTION_GET_USER_BY_NAME));
                rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);

                if (RSPS_OK == status) {
                    String name, fullName;
                    long gid = pkt.getLongAutoInc();
                    int bytes = pkt.getShortAutoInc();
                    name = pkt.getStringAutoInc(bytes);
                    bytes = pkt.getShortAutoInc();
                    fullName = pkt.getStringAutoInc(bytes);

                    rspsIntent.putExtra("id", gid);
                    rspsIntent.putExtra("name", name);
                    rspsIntent.putExtra("fullName", fullName);
                    LPreferences.setShareUserId(gid, name);
                    LPreferences.setShareUserName(gid, fullName);
                }
                LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);*/
                break;

            case LProtocol.RSPS | LProtocol.RQST_RESET_PASSWORD:
                /*rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver.ACTION_UI_RESET_PASSWORD));
                rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);
                LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);*/
                break;

            case LProtocol.RSPS | LProtocol.RQST_POST_JOURNAL:
                /*packetConsumptionStatus.isResponseCompleted = (status != RSPS_MORE);
                rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver.ACTION_POST_JOURNAL));
                rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);
                if (LProtocol.RSPS_OK == status || LProtocol.RSPS_MORE == status) {
                    int journalId = pkt.getIntAutoInc();
                    rspsIntent.putExtra("journalId", journalId);
                    short jrqstId = pkt.getShortAutoInc();
                    rspsIntent.putExtra("jrqstId", jrqstId);
                    short jret = pkt.getShortAutoInc();
                    rspsIntent.putExtra("jret", jret);

                    switch (jrqstId) {
                    case LProtocol.JRQST_ADD_ACCOUNT:
                        if (LProtocol.RSPS_OK == jret) {
                            rspsIntent.putExtra("id", pkt.getLongAutoInc());
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("uid", pkt.getLongAutoInc());
                        }
                        break;
                    case LProtocol.JRQST_ADD_CATEGORY:
                    case LProtocol.JRQST_ADD_VENDOR:
                    case LProtocol.JRQST_ADD_TAG:
                    case LProtocol.JRQST_ADD_RECORD:
                    case LProtocol.JRQST_ADD_SCHEDULE:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("id", pkt.getLongAutoInc());
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                        }
                        break;
                    case LProtocol.JRQST_GET_ACCOUNTS:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("uid", pkt.getLongAutoInc());
                            int bytes = pkt.getShortAutoInc();
                            String name = pkt.getStringAutoInc(bytes);
                            rspsIntent.putExtra("name", name);
                        }
                        break;
                    case LProtocol.JRQST_GET_ACCOUNT_USERS:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("aid", pkt.getLongAutoInc());
                            short length = pkt.getShortAutoInc();
                            String accountUsers = pkt.getStringAutoInc(length);
                            rspsIntent.putExtra("users", accountUsers);
                        }
                        break;
                    case LProtocol.JRQST_GET_CATEGORIES:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("pgid", pkt.getLongAutoInc());
                            short bytes = pkt.getShortAutoInc();
                            String name = pkt.getStringAutoInc(bytes);
                            rspsIntent.putExtra("name", name);
                        }
                        break;
                    case LProtocol.JRQST_GET_VENDORS:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("type", (int) pkt.getByteAutoInc());
                            short bytes = pkt.getShortAutoInc();
                            String name = pkt.getStringAutoInc(bytes);
                            rspsIntent.putExtra("name", name);
                        }
                        break;
                    case LProtocol.JRQST_GET_"\(self)"S:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                            short bytes = pkt.getShortAutoInc();
                            String name = pkt.getStringAutoInc(bytes);
                            rspsIntent.putExtra("name", name);
                        }
                        break;
                    case LProtocol.JRQST_GET_RECORD:
                    case LProtocol.JRQST_GET_RECORDS:
                    case LProtocol.JRQST_GET_ACCOUNT_RECORDS:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("aid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("aid2", pkt.getLongAutoInc());
                            rspsIntent.putExtra("cid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("tid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("vid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("type", pkt.getByteAutoInc());
                            rspsIntent.putExtra("amount", pkt.getDoubleAutoInc());
                            rspsIntent.putExtra("createBy", pkt.getLongAutoInc());
                            rspsIntent.putExtra("changeBy", pkt.getLongAutoInc());
                            rspsIntent.putExtra("recordId", pkt.getLongAutoInc());
                            rspsIntent.putExtra("timestamp", pkt.getLongAutoInc());
                            rspsIntent.putExtra("createTime", pkt.getLongAutoInc());
                            rspsIntent.putExtra("changeTime", pkt.getLongAutoInc());

                            short bytes = pkt.getShortAutoInc();
                            String note = pkt.getStringAutoInc(bytes);
                            rspsIntent.putExtra("note", note);
                        }
                        break;

                    case LProtocol.JRQST_GET_SCHEDULE:
                    case LProtocol.JRQST_GET_SCHEDULES:
                    case LProtocol.JRQST_GET_ACCOUNT_SCHEDULES:
                        if (RSPS_OK == jret) {
                            rspsIntent.putExtra("gid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("aid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("aid2", pkt.getLongAutoInc());
                            rspsIntent.putExtra("cid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("tid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("vid", pkt.getLongAutoInc());
                            rspsIntent.putExtra("type", pkt.getByteAutoInc());
                            rspsIntent.putExtra("amount", pkt.getDoubleAutoInc());
                            rspsIntent.putExtra("createBy", pkt.getLongAutoInc());
                            rspsIntent.putExtra("changeBy", pkt.getLongAutoInc());
                            rspsIntent.putExtra("recordId", pkt.getLongAutoInc());
                            rspsIntent.putExtra("timestamp", pkt.getLongAutoInc());
                            rspsIntent.putExtra("createTime", pkt.getLongAutoInc());
                            rspsIntent.putExtra("changeTime", pkt.getLongAutoInc());

                            short bytes = pkt.getShortAutoInc();
                            String note = pkt.getStringAutoInc(bytes);
                            rspsIntent.putExtra("note", note);

                            rspsIntent.putExtra("nextTime", pkt.getLongAutoInc());
                            rspsIntent.putExtra("interval", pkt.getByteAutoInc());
                            rspsIntent.putExtra("unit", pkt.getByteAutoInc());
                            rspsIntent.putExtra("count", pkt.getByteAutoInc());
                            rspsIntent.putExtra("enabled", pkt.getByteAutoInc());
                        }
                        break;
                    }
                }

                LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);*/
                break;

            case LProtocol.RSPS | LProtocol.RQST_POLL:
                /*packetConsumptionStatus.isResponseCompleted = (status == RSPS_OK || status == RSPS_ERROR);
                rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver.ACTION_POLL));
                rspsIntent.putExtra(LBroadcastReceiver.EXTRA_RET_CODE, status);
                if (status == RSPS_OK) {
                    rspsIntent.putExtra("id", pkt.getLongAutoInc());
                    rspsIntent.putExtra("nid", pkt.getShortAutoInc());
                    rspsIntent.putExtra("int1", pkt.getLongAutoInc());
                    rspsIntent.putExtra("int2", pkt.getLongAutoInc());
                    int bytes = pkt.getShortAutoInc();
                    String txt = pkt.getStringAutoInc(bytes);
                    rspsIntent.putExtra("txt1", txt);
                    bytes = pkt.getShortAutoInc();
                    txt = pkt.getStringAutoInc(bytes);
                    rspsIntent.putExtra("txt2", txt);

                    bytes = pkt.getShortAutoInc();
                    rspsIntent.putExtra("blob", pkt.getBytesAutoInc(bytes));
                }
                LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);*/
                break;

            case LProtocol.RSPS | LProtocol.RQST_POLL_ACK:
                /*if (status == RSPS_OK) {
                    rspsIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver.ACTION_POLL_ACK));
                    LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(rspsIntent);
                } else {
                    LLog.w("\(self)", "unable to acknowledge polling");
                }*/
                break;

            case LProtocol.PUSH_NOTIFICATION:
                LLog.d("\(self)", "push notify received")
                LBroadcast.post(LBroadcast.ACTION_PUSH_NOTIFICATION, sender: nil, data: bdata)
                break;

            default:
                LLog.w("\(self)", "unexpected response: \(rsps) @state: \(state)");
                break;
            }
            break;
        }

        pkt.setOffset(origOffset + Int(total));
        return 1;
    }

    func alignPacket(_ pkt: LBuffer) -> Bool {
        if (pkt.getShort() == LProtocol.PACKET_SIGNATURE1) {
            return true;
        }
        LLog.w("\(self)", "packet misaligned");

        while (pkt.getLen() - pkt.getOffset() >= LProtocol.PACKET_MIN_LEN) {
            if (pkt.getShort() == LProtocol.PACKET_SIGNATURE1) {
                return true;
            }
            pkt.skip(1);
        }
        return false;
    }

    func received(data: UnsafeMutablePointer<UInt8>, bytes: Int) -> Int {
        LLog.d("\(self)", "received data bytes: \(bytes)")
        pktBuf.setBuf(data)
        pktBuf.setOffset(0)
        pktBuf.setLen(bytes)

        while (alignPacket(pktBuf)) {
            let consumed = consumePacket(pktBuf);
            if (consumed == -1) {
                LLog.e("\(self)", "packet parse error? realign packet");
                pktBuf.skip(1)
            } else if (consumed == 0) {
                break;
            } else if (pktBuf.getLen() - pktBuf.getOffset() < LProtocol.PACKET_MIN_LEN) {
                break;
            }
        }

        return pktBuf.getOffset();
    }
}
