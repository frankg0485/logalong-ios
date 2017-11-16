//
//  LTransport.swift
//  LogAlong
//
//  Created by Michael Gao on 11/14/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LTransport {
    static func scramble(buf: inout [UInt8], off: Int, bytes: Int, scrambler: UInt32) {
        var ss = [UInt8](repeating: 0, count: 4);
        ss[0] = UInt8((scrambler >> 24) & 0xff);
        ss[1] = UInt8((scrambler >> 16) & 0xff);
        ss[2] = UInt8((scrambler >> 8) & 0xff);
        ss[3] = UInt8(scrambler & 0xff);

        for ii in 0 ..< bytes {
            buf[off + ii] ^= ss[ii & 0x03];
        }
    }

    static func scramble(_ buf: LBuffer, _ scrambler: UInt32) {
        let len = buf.getShortAt(buf.getBufOffset() + 2)
        if (len < 8) {
            return;
        }

        var a = buf.getBuf()
        scramble(buf: &a, off: buf.getBufOffset() + 6, bytes: Int(len - 6) , scrambler: scrambler)
        buf.setBuf(a)
    }

    static func do_crc32(_ buf: LBuffer) {
        let crc = crc32(0, buffer: buf.getBuf(), length: buf.getLen())
        buf.putIntAt(crc, buf.getLen())
        buf.setLen(buf.getLen() + 4)
    }

    static func send_rqst(rqst: UInt16, d32: UInt32, d161: UInt16, d162: UInt16, scrambler: UInt32) {
        let buf = LBuffer(size: 32);

        buf.putShortAutoInc(LProtocol.PACKET_SIGNATURE1);
        buf.putShortAutoInc(16);

        buf.putShortAutoInc(rqst);
        buf.putIntAutoInc(d32);
        buf.putShortAutoInc(d161);
        buf.putShortAutoInc(d162);
        buf.setLen(16);

        buf.setBufOffset(0);
        scramble(buf, scrambler);

        do_crc32(buf);
        LServer.instance.send(data: buf.getBuf(), bytes: buf.getLen())
    }
}
