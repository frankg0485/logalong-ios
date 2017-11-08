//
//  Server.swift
//  LogAlong
//
//  Created by Michael Gao on 11/5/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

//protocol LServerDelegate: class {
//    func receivedPacket(packet: LPacket)
//}

class LServer: NSObject {
    //weak var delegate: ChatRoomDelegate?

    var inputStream: InputStream!
    var outputStream: OutputStream!

    var username = ""

    let PORT_NO = 8000
    let SERVER_NAME = "192.168.1.116"

    let maxReadLength = 1024

    func connect() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           SERVER_NAME as CFString,
                                           UInt32(PORT_NO),
                                           &readStream,
                                           &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

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

    func send(message: String) {
        let data = "msg:\(message)".data(using: .ascii)!

        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
}

extension LServer: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received")
            recv(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            disconnect()
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
            break
        }
    }

    private func recv(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

            if numberOfBytesRead < 0 {
                if let _ = inputStream.streamError {
                    break
                }
            }

            //if let pkt = recvPacket(buffer: buffer, length: numberOfBytesRead) {
            //    delegate?.receivedPacket(packet: pkt)
            //}
        }
    }
}
