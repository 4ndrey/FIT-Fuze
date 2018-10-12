//
//  DataCompressor.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 12.10.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation
import Compression

class DataCompressor {
    private static let algorithm = COMPRESSION_ZLIB

    class func compress(data: Data) -> Data {
        let sourceBuffer = [UInt8](data)

        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer { destinationBuffer.deallocate() }

        let compressedSize = compression_encode_buffer(destinationBuffer, data.count,
                                                       sourceBuffer, data.count,
                                                       nil,
                                                       DataCompressor.algorithm)
        if compressedSize == 0 {
            return data // compression failed, return original data
        } else {
            return Data(bytes: destinationBuffer, count: compressedSize)
        }
    }

    class func decompress(data: Data, expectedSize: Int) -> Data {
        var encodedSourceBuffer = [UInt8](data)

        let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: expectedSize)
        defer { decodedDestinationBuffer.deallocate() }

        let decodedSize = compression_decode_buffer(decodedDestinationBuffer, expectedSize,
                                                    encodedSourceBuffer, data.count,
                                                    nil,
                                                    DataCompressor.algorithm)
        if decodedSize == 0 {
            return data // decompression failed, return original data
        } else {
            return Data(bytes: decodedDestinationBuffer, count: decodedSize)
        }
    }
}
