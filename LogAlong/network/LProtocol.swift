//
//  LProtocol.swift
//  LogAlong
//
//  Created by Michael Gao on 11/14/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

final class LProtocol : LServerDelegate {
    static let instance = LProtocol()

    static let PACKET_MAX_PAYLOAD_LEN = 1456;
    static let PACKET_MAX_LEN = (PACKET_MAX_PAYLOAD_LEN + 8);
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

    static func PACKET_PAYLOAD_LENGTH(payloadLen: Int) -> Int {
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

    var scrambler: UInt32 = 0;
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
        let scrambler = genScrambler();
        let version : UInt16 = 1; //TODO: get app version on the fly
        let iosId : UInt16 = 2;
        LTransport.send_rqst(rqst: LProtocol.RQST_SCRAMBLER_SEED, d32: scrambler,
                             d161: version, d162: iosId, scrambler: 0);
    }

    func receivedPacket(pkt: UnsafeMutablePointer<UInt8>, bytes: Int) -> Int {
        print("receiving packet bytes: \(bytes)")
        return 0;
    }
}
