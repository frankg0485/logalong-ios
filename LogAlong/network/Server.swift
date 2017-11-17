//
//  Server.swift
//  LogAlong
//
//  Created by Michael Gao on 11/5/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

protocol LServerDelegate: class {
    func start()
    func received(data: UnsafeMutablePointer<UInt8>, bytes: Int) -> Int
}

final class LServer: NSObject {
    let TAG = "LServer"
    weak var delegate: LServerDelegate!
    static let instance = LServer()

    let rxQ = DispatchQueue(label: "com.swoag.logalong.receive")
    let txQ = DispatchQueue(label: "com.swoag.logalong.transmit")

    static let MAX_RX_BYTES = LProtocol.PACKET_MAX_LEN
    static let MIN_PACKET_BYTES = LProtocol.PACKET_MIN_LEN
    var rxBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: LServer.MAX_RX_BYTES * 2)
    var rxBytes = 0;

    var inputStream: InputStream!
    var outputStream: OutputStream!
    var streamCount = 0;

    var username = ""

    static let PORT_NO = 8000
    static let SERVER_NAME = "192.168.1.116"

    func connect() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           LServer.SERVER_NAME as CFString,
                                           UInt32(LServer.PORT_NO),
                                           &readStream,
                                           &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        streamCount = 0;

        inputStream.delegate = self
        outputStream.delegate = self

        inputStream.schedule(in: .main, forMode: .commonModes)
        outputStream.schedule(in: .main, forMode: .commonModes)

        inputStream.open()
        outputStream.open()
    }

    func disconnect() {
        inputStream.close()
        outputStream.close()
    }

    func send(data: UnsafeMutablePointer<UInt8>, bytes: Int) {
        let array = Array(UnsafeBufferPointer(start: data, count: bytes))
        txQ.async {
            self.outputStream.write(array, maxLength: bytes)
        }
    }
}

extension LServer: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            LLog.d(TAG, "new message received")
            rxQ.async {
                self.recv(stream: aStream as! InputStream)
            }
        case Stream.Event.endEncountered:
            disconnect()
        case Stream.Event.errorOccurred:
            //TODO: retry connection after some waiting
            LLog.e(TAG, "error occurred")
        case Stream.Event.hasSpaceAvailable:
            LLog.d(TAG, "has space available")
        case Stream.Event.openCompleted:
            streamCount += 1
            if streamCount == 2 {
                delegate.start()
            }
        default:
            LLog.d(TAG, "some other event...")
            break
        }
    }

    private func recv(stream: InputStream) {
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(rxBuffer + rxBytes, maxLength: LServer.MAX_RX_BYTES)
            if numberOfBytesRead < 0 {
                if let _ = inputStream.streamError {
                    LLog.w(TAG, "input stream error")
                    break
                }
            } else {
                rxBytes += numberOfBytesRead;
                if (rxBytes >= LServer.MIN_PACKET_BYTES) {
                    let consumedBytes = (delegate.received(data: rxBuffer, bytes: rxBytes))
                    memmove(rxBuffer, rxBuffer + consumedBytes, rxBytes - consumedBytes);
                    rxBytes -= consumedBytes;
                }
            }
        }
    }
}
