//
//  LBuffer.swift
//  LogAlong
//
//  Created by Michael Gao on 11/14/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LBuffer {
    var bytes = 0; // current valid bytes in buffer: when reading, bytes tracks number of bytes left in buffer
    var offset = 0; // current read/write position
    var array: UnsafeMutablePointer<UInt8>!;

    init (size: Int) {
        if size > 0 {
            array = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        }
        offset = 0;
        bytes = 0;
    }

    func getBuf() -> UnsafeMutablePointer<UInt8> {
        return array;
    }

    func setBuf(_ array: UnsafeMutablePointer<UInt8>) {
        self.array = array;
        offset = 0;
        bytes = 0;
    }

    func getOffset() -> Int {
        return offset;
    }

    func setOffset(_ offset: Int) {
        self.offset = offset;
    }

    func size() -> Int {
        return 0;
    }

    func getLen() -> Int {
        return self.bytes;
    }

    func setLen(_ bytes: Int) {
        self.bytes = bytes;
    }

    /*
     public int append(byte[] buf) {
     if (offset + bytes + buf.length > array.length) {
     LLog.e(TAG, "buffer overlow: " + buf.length + "@" + bytes + " offset: " + offset);
     return -1;
     }
     System.arraycopy(buf, 0, array, offset + bytes, buf.length);
     bytes += buf.length;
     return 0;
     }

     public int append(LBuffer buf) {
     int len = buf.getLen();
     if (offset + bytes + len > array.length) {
     LLog.e(TAG, "buffer overlow: " + len + "@" + bytes + " offset: " + offset);
     return -1;
     }
     System.arraycopy(buf.getBuf(), 0, array, offset + bytes, len);
     bytes += len;
     return 0;
     }
     */

    func getShortAt(_ off: Int) -> UInt16 {
        var val = UInt16(array[off] & 0xff);
        val += (0xff00 & UInt16(array[off + 1]) << 8);
        return val;
    }

    func getShort() -> UInt16 {
        var val = UInt16(array[offset] & 0xff);
        val += (0xff00 & UInt16(array[offset + 1]) << 8);
        return val;
    }

    func getIntAt(_ off: Int) -> UInt32 {
        var val = UInt32(array[off] & 0xff);
        val += UInt32(0xff00 & (UInt32(array[off + 1]) << 8));
        val += UInt32(0xff0000 & ((UInt32(array[off + 2]) << 16)));
        val += UInt32(0xff000000 & ((UInt32(array[off + 3]) << 24)));
        return val;
    }

    /*
     public byte getByteAutoInc() {
     offset++;
     return array[offset - 1];
     }*/

    func getShortAutoInc() -> UInt16 {
        var val = UInt16(array[offset] & 0xff);
        val += (0xff00 & UInt16(array[offset + 1]) << 8);
        offset += 2;
        return val;
    }

    /*
     public int getIntAutoInc() {
     int ret = (array[offset] & 0xff) |
     (0xff00 & (array[offset + 1] << 8)) |
     (0xff0000 & (array[offset + 2] << 16)) |
     (0xff000000 & (array[offset + 3] << 24));
     offset += 4;
     return ret;
     }

     public double getDoubleAutoInc() {
     long bits = getLongAutoInc();
     return Double.longBitsToDouble(bits);
     }

     public long getLongAutoInc() {
     long ret = (array[offset] & 0xffL) |
     (0xff00L & (array[offset + 1] << 8)) |
     (0xff0000L & (array[offset + 2] << 16)) |
     (0xff000000L & (array[offset + 3] << 24)) |
     (0xff00000000L & ((long) array[offset + 4] << 32)) |
     (0xff0000000000L & ((long) array[offset + 5] << 40)) |
     (0xff000000000000L & ((long) array[offset + 6] << 48)) |
     (0xff00000000000000L & ((long) array[offset + 7] << 56));
     offset += 8;
     return ret;
     }

     public byte[] getBytesAutoInc(int bytes) {
     byte[] tmp = new byte[bytes];
     System.arraycopy(array, offset, tmp, 0, bytes);
     offset += bytes;

     return tmp;
     }

     public short[] getShortsAutoInc(int shorts) {
     short[] tmp = new short[shorts];
     for (int ii = 0; ii < shorts; ii++)
     tmp[ii] = getShortAutoInc();

     return tmp;
     }

     public int[] getIntsAutoInc(int ints) {
     int[] tmp = new int[ints];
     for (int ii = 0; ii < ints; ii++)
     tmp[ii] = getIntAutoInc();
     return tmp;
     }

     public String getStringAutoInc(int bytes) {
     byte[] tmp = new byte[bytes];
     System.arraycopy(array, offset, tmp, 0, bytes);
     offset += bytes;
     try {
     return new String(tmp, "UTF-8");
     } catch (Exception e) {
     LLog.w(TAG, "unable to decode string");
     }
     return null;
     }

     public int putByteAutoInc(byte b) {
     array[offset] = b;
     offset++;
     return 0;
     }
     */

    func putShortAutoInc(_ val: UInt16) {
        array[offset] = UInt8(val & 0xff);
        array[offset + 1] = UInt8(val >> 8);
        offset += 2;
    }

    /*
     public int putShortAt(short val, int index) {
     array[index] = (byte) (val & 0xff);
     array[index + 1] = (byte) ((val >>> 8) & 0xff);
     return 0;
     }
     */

    func putIntAutoInc(_ val: UInt32) {
        array[offset] = UInt8(val & 0xff);
        array[offset + 1] = UInt8((val >> 8) & 0xff);
        array[offset + 2] = UInt8((val >> 16) & 0xff);
        array[offset + 3] = UInt8((val >> 24) & 0xff);
        offset += 4;
    }

    func putIntAt(_ val: UInt32, _ index: Int) {
        array[index] = UInt8(val & 0xff);
        array[index + 1] = UInt8((val >> 8) & 0xff);
        array[index + 2] = UInt8((val >> 16) & 0xff);
        array[index + 3] = UInt8((val >> 24) & 0xff);
    }

    /*
     public int putLongAutoInc(long val) {
     array[offset] = (byte) (val & 0xff);
     array[offset + 1] = (byte) ((val >>> 8) & 0xff);
     array[offset + 2] = (byte) ((val >>> 16) & 0xff);
     array[offset + 3] = (byte) ((val >>> 24) & 0xff);
     array[offset + 4] = (byte) ((val >>> 32) & 0xff);
     array[offset + 5] = (byte) ((val >>> 40) & 0xff);
     array[offset + 6] = (byte) ((val >>> 48) & 0xff);
     array[offset + 7] = (byte) ((val >>> 56) & 0xff);
     offset += 8;
     return 0;
     }

     public int putDoubleAutoInc(double val) {
     long bits = Double.doubleToLongBits(val);
     return putLongAutoInc(bits);
     }

     public int putStringAutoInc(String str) {
     try {
     byte[] bytes = str.getBytes("UTF-8");
     System.arraycopy(bytes, 0, array, offset, bytes.length);
     offset += bytes.length;
     return 0;
     } catch (Exception e) {
     }
     return -1;
     }

     public int putBytesAutoInc(byte[] bytes) {
     System.arraycopy(bytes, 0, array, offset, bytes.length);
     offset += bytes.length;
     return 0;
     }

     public int putBytesAutoInc(byte[] bytes, int off, int length) {
     System.arraycopy(bytes, off, array, offset, length);
     offset += length;
     return 0;
     }

     public int putShortsAutoInc(short[] shorts) {
     int len = shorts.length;
     if (len == 0) return 0;

     byte[] bytes = new byte[len << 2];

     for (int ii = 0, jj = 0; ii < len; ii++) {
     short val = shorts[ii];
     bytes[jj++] = (byte) ((val) & 0xff);
     bytes[jj++] = (byte) ((val >>> 8) & 0xff);
     }

     System.arraycopy(bytes, 0, array, offset, bytes.length);
     offset += bytes.length;
     return 0;
     }

     public int putIntsAutoInc(int[] ints) {
     int len = ints.length;
     if (len == 0) return 0;
     byte[] bytes = new byte[len << 2];

     for (int ii = 0, jj = 0; ii < len; ii++) {
     int val = ints[ii];
     bytes[jj++] = (byte) ((val) & 0xff);
     bytes[jj++] = (byte) ((val >>> 8) & 0xff);
     bytes[jj++] = (byte) ((val >>> 16) & 0xff);
     bytes[jj++] = (byte) ((val >>> 24) & 0xff);
     }

     System.arraycopy(bytes, 0, array, offset, bytes.length);
     offset += bytes.length;
     return 0;
     }

     public int putIntsAutoInc(int[] ints, int off, int count) {
     LLog.d(TAG, "off: " + off + " count: " + count + "/" + ints.length);
     if (count == 0) return 0;
     byte[] bytes = new byte[count << 2];

     for (int ii = 0, jj = 0; ii < count; ii++) {
     int val = ints[ii + off];
     bytes[jj++] = (byte) ((val) & 0xff);
     bytes[jj++] = (byte) ((val >>> 8) & 0xff);
     bytes[jj++] = (byte) ((val >>> 16) & 0xff);
     bytes[jj++] = (byte) ((val >>> 24) & 0xff);
     }

     System.arraycopy(bytes, 0, array, offset, bytes.length);
     offset += bytes.length;
     return 0;
     }
     */

    func modLen(_ mod: Int) {
        bytes += mod;
    }

    func skip(_ bytes: Int) {
        offset += bytes;
    }

    /*
     public void setOffset(int off) {
     offset = off;
     }

     public void clear() {
     offset = 0;
     bytes = 0;
     }

     public void reset() {
     if (offset != 0) {
     //byte[] a = new byte[array.length];
     System.arraycopy(array, offset, array, 0, bytes);
     offset = 0;
     //array = a;
     }
     }

     public LBuffer dup() {
     LBuffer buf = new LBuffer(size());
     System.arraycopy(array, 0, buf.getBuf(), 0, array.length);
     buf.setLen(array.length);
     return buf;
     }*/
}


