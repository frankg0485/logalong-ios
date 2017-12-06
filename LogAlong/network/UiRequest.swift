//
//  UiRequest.swift
//  LogAlong
//
//  Created by Michael Gao on 11/21/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

enum UiConnectionState {
    case CONNECTING
    case DISCONNECTED
    case CONNECTED
    case LOGGED_IN
}

class UiRequest: NSObject {
    var state = UiConnectionState.CONNECTING;

    static let instance = UiRequest()

    override init() {
        super.init()
        LBroadcast.register(LBroadcast.ACTION_NETWORK_CONNECTED, cb: #selector(self.networkConnected), listener: self)
        LBroadcast.register(LBroadcast.ACTION_NETWORK_DISCONNECTED, cb: #selector(self.networkDisConnected), listener: self)
    }

    deinit {
        LBroadcast.unregister(LBroadcast.ACTION_NETWORK_CONNECTED, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_NETWORK_DISCONNECTED, listener: self)
    }

    @objc func networkConnected(notification: Notification) -> Void {
        state = UiConnectionState.CONNECTED;
        if !LPreferences.getUserId().isEmpty {
            UiLogIn(LPreferences.getUserId(), LPreferences.getUserPassword())
        }
    }

    @objc func networkDisConnected(notification: Notification) -> Void {
        state = UiConnectionState.DISCONNECTED;
    }

    func UiGetUserByName(_ name: String) -> Bool {
        LTransport.send_rqst(LProtocol.RQST_GET_USER_BY_NAME, string: name, scrambler: LProtocol.instance.scrambler);
        return true;
    }

    func UiCreateUser(_ name: String, _ pass: String, fullname: String) -> Bool {
        var strings = [String]()
        strings.append(name)
        strings.append(pass)
        strings.append(fullname);
        LTransport.send_rqst(LProtocol.RQST_CREATE_USER, strings: strings, scrambler: LProtocol.instance.scrambler);
        return true;
    }

    func UiSignIn(_ name: String, _ pass: String) -> Bool {
        var strings = [String]()
        strings.append(name)
        strings.append(pass)
        LTransport.send_rqst(LProtocol.RQST_SIGN_IN, strings: strings, scrambler: LProtocol.instance.scrambler);
        return true;
    }

    func UiUpdateUserProfile(_ name: String, _ pass: String, newPass: String, fullName: String) -> Bool {
        var strings = [String]()
        strings.append(name)
        strings.append(pass)
        strings.append(newPass)
        strings.append(fullName);
        LTransport.send_rqst(LProtocol.RQST_UPDATE_USER_PROFILE, strings: strings, scrambler: LProtocol.instance.scrambler);
        return true;
    }

    func UiLogIn(_ name: String, _ pass: String) -> Bool {
        var strings = [String]()
        strings.append(name)
        strings.append(pass)
        strings.append(LPreferences.getDeviceId());
        LTransport.send_rqst(LProtocol.RQST_LOG_IN, strings: strings, scrambler: LProtocol.instance.scrambler);
        return true;
    }

    func UiResetPassword(_ name: String, email: String) -> Bool {
        var strings = [String]()
        strings.append(name)
        strings.append(email)
        LTransport.send_rqst(LProtocol.RQST_RESET_PASSWORD, strings: strings, scrambler: LProtocol.instance.scrambler)
        return true
    }

    func UiPoll() -> Bool {
        LTransport.send_rqst(LProtocol.RQST_POLL, scrambler: LProtocol.instance.scrambler)
        return true
    }

    func UiPollAck(_ id: Int64) -> Bool {
        LTransport.send_rqst(LProtocol.RQST_POLL_ACK, d64: id, scrambler: LProtocol.instance.scrambler)
        return true
    }

    func UiPostJournal(_ journalId: Int, data: [UInt8]) -> Bool {
        LTransport.send_rqst(LProtocol.RQST_POST_JOURNAL, d32: UInt32(journalId), datab: data, scrambler: LProtocol.instance.scrambler);
        return true
    }
}
