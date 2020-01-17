//
//  ZappyServerInteraction.swift
//  ZappyGo
//
//  Created by Quentin Liardeaux on 6/17/19.
//  Copyright © 2019 Quentin Liardeaux. All rights reserved.
//

import Foundation;

protocol ServerDelegate: class {
    func receive(map: srv_map_size_t)
    func receive(tile: srv_tile_content_t)
}

class ServerCommunication: NSObject {
    private var inputStream: InputStream
    private var outputStream: OutputStream
    var maxReadLength = 4096
    weak var delegate: ServerDelegate? {
        didSet {
            inputStream.delegate = self
            if (inputStream.hasBytesAvailable) {
                readAvailableBytes(stream: inputStream)
            }
            print("input \(inputStream.hasBytesAvailable)")
        }
    }

    init(port: UInt32, hostname: String = "localhost") {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, hostname as CFString, port, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        inputStream.open()
        outputStream.open()
        super.init()
    }

    func send(message: String) {
        let data = message.data(using: .ascii)!

        _ = data.withUnsafeBytes({ outputStream.write($0, maxLength: data.count) })
    }
    
    func send(hdr: pkt_header_t, map: clt_map_size_t) {
        let hdrSize = MemoryLayout<pkt_header_t>.size
        let mapSize = MemoryLayout<clt_map_size_t>.size
        let hdrPointer = UnsafeMutablePointer<pkt_header_t>.allocate(capacity: 1)
        let mapPointer = UnsafeMutablePointer<clt_map_size_t>.allocate(capacity: 1)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: hdrSize + mapSize)
        
        hdrPointer.initialize(to: hdr)
        mapPointer.initialize(to: map)
        
        let hdrBuffer = hdrPointer.withMemoryRebound(to: UInt8.self, capacity: hdrSize, { $0 })
        let mapBuffer = mapPointer.withMemoryRebound(to: UInt8.self, capacity: mapSize, { $0 })

        buffer.assign(from: hdrBuffer, count: hdrSize)
        buffer.advanced(by: hdrSize).assign(from: mapBuffer, count: mapSize)
        outputStream.write(buffer, maxLength: hdrSize + mapSize)
        hdrPointer.deallocate()
        mapPointer.deallocate()
        buffer.deallocate()
    }
    
    private func getBytes(buffer: UnsafeMutablePointer<UInt8>, size: Int, offset: Int) -> [UInt8] {
        var bytes: [UInt8] = []
        
        for i in 0 ..< size {
            bytes.append(buffer[i + offset])
        }
        return (bytes)
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        var i: Int = 0

        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

            if (numberOfBytesRead < 0) {
                if let _ = stream.streamError {
                    return
                }
            }
            while ( i < numberOfBytesRead) {
                var tmp = buffer + i
                let hdr = tmp.withMemoryRebound(to: pkt_header_t.self, capacity: MemoryLayout<pkt_header_t>.size, { $0 })

                i += MemoryLayout<pkt_header_t>.size
                tmp = buffer + i
                if (hdr.pointee.id == UInt8(SRV_MAP_SIZE.rawValue)) {
                    let map = tmp.withMemoryRebound(to: srv_map_size_t.self, capacity: MemoryLayout<srv_map_size_t>.size, { $0 })
                    delegate?.receive(map: map.pointee)
                } else if (hdr.pointee.id == UInt8(SRV_TILE_CONTENT.rawValue)) {
                    let tile = tmp.withMemoryRebound(to: srv_tile_content_t.self, capacity: MemoryLayout<srv_tile_content_t>.size, { $0 })
                    delegate?.receive(tile: tile.pointee)
                }
                i += Int(hdr.pointee.size)
            }
            i = 0
        }
    }
}

extension ServerCommunication: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
        default:
            return
        }
    }
}
