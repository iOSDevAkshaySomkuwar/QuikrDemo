//
//  AVCodecParser.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/1.
//

import CFFmpeg

// MARK: - AVCodecParser

typealias CAVCodecParser = CFFmpeg.AVCodecParser

public struct AVCodecParser {
    let cParserPtr: UnsafeMutablePointer<CAVCodecParser>
    var cParser: CAVCodecParser { cParserPtr.pointee }

    init(cParserPtr: UnsafeMutablePointer<CAVCodecParser>) {
        self.cParserPtr = cParserPtr
    }

    /// several codec IDs are permitted
    public var codecIds: [AVCodecID] {
        let list = [
            cParser.codec_ids.0, cParser.codec_ids.1, cParser.codec_ids.2, cParser.codec_ids.3
        ]
        return list.map({ AVCodecID(UInt32($0)) }).filter({ $0 != .none })
    }

    /// Get all registered codec parsers.
    public static var supportedParsers: [AVCodecParser] {
        var list = [AVCodecParser]()
        var state: UnsafeMutableRawPointer?
        while let fmtPtr = av_parser_iterate(&state) {
            list.append(AVCodecParser(cParserPtr: fmtPtr.mutable))
        }
        return list
    }
}

// MARK: - AVCodecParserContext

public typealias AVCodecParserResult = (
    UnsafeMutablePointer<UInt8>?, // The parsed buffer or nil if not yet finished.
    Int, // The number of bytes of the parsed buffer or zero if not yet finished.
    Int // The number of bytes of the input bitstream used.
)

typealias CAVCodecParserContext = CFFmpeg.AVCodecParserContext

public final class AVCodecParserContext {
    private let codecContext: AVCodecContext
    private let cContextPtr: UnsafeMutablePointer<CAVCodecParserContext>
    private var cContext: CAVCodecParserContext { cContextPtr.pointee }

    public init?(codecContext: AVCodecContext) {
        precondition(codecContext.codec != nil, "'AVCodecContext.codec' must not be nil.")

        guard let ctxPtr = av_parser_init(Int32(codecContext.codec!.id.rawValue)) else {
            return nil
        }
        self.codecContext = codecContext
        self.cContextPtr = ctxPtr
    }

    /// Parse a packet.
    ///
    /// - Parameters:
    ///   - data: input buffer.
    ///   - size: buffer size in bytes without the padding.
    ///     I.e. the full buffer size is assumed to be `buf_size + AVConstant.inputBufferPaddingSize`.
    ///     To signal EOF, this should be 0 (so that the last frame can be output).
    ///   - pts: input presentation timestamp.
    ///   - dts: input decoding timestamp.
    ///   - pos: input byte position in stream.
    /// - Returns: The parsed result.
    /// - Throws: AVError
    public func parse(
        data: UnsafePointer<UInt8>,
        size: Int,
        pts: Int64 = AVTimestamp.noPTS,
        dts: Int64 = AVTimestamp.noPTS,
        pos: Int64 = 0
    ) throws -> AVCodecParserResult {
        var buf: UnsafeMutablePointer<UInt8>?
        var bufSize: Int32 = 0
        let ret = av_parser_parse2(
            cContextPtr,
            codecContext.cContextPtr,
            &buf,
            &bufSize,
            data,
            Int32(size),
            pts,
            dts,
            pos
        )
        try throwIfFail(ret)

        return (buf, Int(bufSize), Int(ret))
    }

    deinit {
        av_parser_close(cContextPtr)
    }
}
