//
//  AVFrame.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVFrame

typealias CAVFrame = CFFmpeg.AVFrame

/// This structure describes decoded (raw) audio or video data.
///
/// `AVFrame` is typically allocated once and then reused multiple times to hold
/// different data (e.g. a single `AVFrame` to hold frames received from a decoder).
/// In such a case, `unref()` will free any references held by the frame and reset it
/// to its original clean state before it is reused again.
///
/// The data described by an `AVFrame` is usually reference counted through the
/// `AVBuffer` API. The underlying buffer references are stored in `buffer` /
/// `extendedBuffer`. An `AVFrame` is considered to be reference counted if at
/// least one reference is set, i.e. if `buffer[0] != nil`. In such a case,
/// every single data plane must be contained in one of the buffers in `buffer`
/// or `extendedBuffer`.
/// There may be a single buffer for all the data, or one separate buffer for
/// each plane, or anything in between.
public final class AVFrame {
    let cFramePtr: UnsafeMutablePointer<CAVFrame>
    var cFrame: CAVFrame { cFramePtr.pointee }

    init(cFramePtr: UnsafeMutablePointer<CAVFrame>) {
        self.cFramePtr = cFramePtr
    }

    /// Creates an `AVFrame` and set its fields to default values.
    ///
    /// - Note: This only allocates the `AVFrame` itself, not the data buffers.
    ///   Those must be allocated through other means, e.g. with `allocBuffer(align:)` or manually.
    public init() {
        guard let framePtr = av_frame_alloc() else {
            abort("av_frame_alloc")
        }
        self.cFramePtr = framePtr
    }

    /// Pointer to the picture/channel planes.
    public var data: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>?> {
        get {
            return withUnsafeMutableBytes(of: &cFramePtr.pointee.data) { ptr in
                return ptr.bindMemory(to: UnsafeMutablePointer<UInt8>?.self)
            }
        }
        set {
            withUnsafeMutableBytes(of: &cFramePtr.pointee.data) { ptr in
                ptr.copyMemory(from: UnsafeRawBufferPointer(newValue))
            }
        }
    }

    /// For video, size in bytes of each picture line.
    /// For audio, size in bytes of each plane.
    ///
    /// For audio, only `linesize[0]` may be set.
    /// For planar audio, each channel plane must be the same size.
    ///
    /// For video the linesizes should be multiples of the CPUs alignment preference, this is 16 or 32
    /// for modern desktop CPUs. Some code requires such alignment other code can be slower without correct
    /// alignment, for yet other it makes no difference.
    ///
    /// - Note: The linesize may be larger than the size of usable data -- there may be extra padding present
    ///   for performance reasons.
    public var linesize: UnsafeMutableBufferPointer<Int32> {
        get {
            return withUnsafeMutableBytes(of: &cFramePtr.pointee.linesize) { ptr in
                return ptr.bindMemory(to: Int32.self)
            }
        }
        set {
            withUnsafeMutableBytes(of: &cFramePtr.pointee.linesize) { ptr in
                ptr.copyMemory(from: UnsafeRawBufferPointer(newValue))
            }
        }
    }

    /// pointers to the data planes/channels.
    ///
    /// For video, this should simply point to `data`.
    ///
    /// For planar audio, each channel has a separate data pointer, and `linesize[0]` contains
    /// the size of each channel buffer.
    /// For packed audio, there is just one data pointer, and `linesize[0]` contains
    /// the total size of the buffer for all channels.
    ///
    /// - Note: Both `data` and `extendedData` should always be set in a valid frame,
    ///   but for planar audio with more channels that can fit in `data`,
    ///   `extendedData` must be used in order to access all channels.
    public var extendedData: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>?> {
        get {
            let count = pixelFormat != .none ? 4 : channelCount
            return UnsafeMutableBufferPointer(start: cFrame.extended_data, count: count)
        }
        set { cFramePtr.pointee.extended_data = newValue.baseAddress }
    }

    /// Presentation timestamp in timebase units (time when frame should be shown to user).
    public var pts: Int64 {
        get { cFrame.pts }
        set { cFramePtr.pointee.pts = newValue }
    }

    /// DTS copied from the `AVPacket` that triggered returning this frame. (if frame threading isn't used)
    /// This is also the presentation time of this `AVFrame` calculated from only `AVPacket.dts` values
    /// without pts values.
    public var dts: Int64 {
        cFrame.pkt_dts
    }

    /// Picture number in bitstream order.
    public var codedPictureNumber: Int {
        Int(cFrame.coded_picture_number)
    }

    /// Picture number in display order.
    public var displayPictureNumber: Int {
        Int(cFrame.display_picture_number)
    }

    /// `AVBuffer` references backing the data for this frame.
    ///
    /// If all elements of this array are `nil`, then this frame is not reference counted.
    /// This array must be filled contiguously -- if `buffer[i]` is non-nil then `buffer[j]` must
    /// also be non-nil for all `j < i`.
    ///
    /// There may be at most one `AVBuffer` per data plane, so for video this array always
    /// contains all the references. For planar audio with more than `AVConstant.dataPointersNumber`
    /// channels, there may be more buffers than can fit in this array. Then the extra
    /// `AVBuffer` are stored in the `extendedBuffer` array.
    public var buffer: [AVBuffer?] {
        let list = [
            cFrame.buf.0, cFrame.buf.1, cFrame.buf.2, cFrame.buf.3,
            cFrame.buf.4, cFrame.buf.5, cFrame.buf.6, cFrame.buf.7
        ]
        return list.map({ $0 != nil ? AVBuffer(cBufferPtr: $0!) : nil })
    }

    /// For planar audio which requires more than `AVConstant.dataPointersNumber` `AVBuffer`,
    /// this array will hold all the references which cannot fit into `buffer`.
    ///
    /// Note that this is different from `extendedData`, which always contains all the pointers.
    /// This array only contains the extra pointers, which cannot fit into `buffer`.
    public var extendedBuffer: [AVBuffer] {
        var list = [AVBuffer]()
        for i in 0..<extendedBufferCount {
            list.append(AVBuffer(cBufferPtr: cFrame.extended_buf[i]!))
        }
        return list
    }

    /// The number of elements in `extendedBuffer`.
    public var extendedBufferCount: Int {
        Int(cFrame.nb_extended_buf)
    }

    /// The frame timestamp estimated using various heuristics, in stream timebase.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var bestEffortTimestamp: Int64 {
        cFrame.best_effort_timestamp
    }

    /// Reordered pos from the last `AVPacket` that has been input into the decoder.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var pktPosition: Int64 {
        cFrame.pkt_pos
    }

    /// Duration of the corresponding packet, expressed in `AVStream.timebase` units, 0 if unknown.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var pktDuration: Int64 {
        cFrame.pkt_duration
    }

    /// Size of the corresponding packet containing the compressed frame.
    /// It is set to a negative value if unknown.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var pktSize: Int {
        Int(cFrame.pkt_size)
    }

    /// The metadata of the frame.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by libavcodec.
    public var metadata: [String: String] {
        get {
            var dict = [String: String]()
            var tag: UnsafeMutablePointer<AVDictionaryEntry>?
            while let next = av_dict_get(cFrame.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
                dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
                tag = next
            }
            return dict
        }
        set {
            var ptr = cFramePtr.pointee.metadata
            for (k, v) in newValue {
                av_dict_set(&ptr, k, v, AV_OPT_SEARCH_CHILDREN)
            }
            cFramePtr.pointee.metadata = ptr
        }
    }

    /// A Boolean value indicating whether the frame data is writable.
    ///
    /// `true` if the frame data is writable (which is `true` if and only if each of the
    /// underlying buffers has only one reference, namely the one stored in this frame).
    public var isWritable: Bool {
        av_frame_is_writable(cFramePtr) > 0
    }

    /// Allocate new buffer(s) for audio or video data.
    ///
    /// The following fields must be set on frame before calling this function:
    ///   - `pixelFormat` for video, `sampleFormat` for audio
    ///   - `width` and `height` for video
    ///   - `sampleCount` and `channelLayout` for audio
    ///
    /// This function will fill `data` and `buffer` arrays and, if necessary,
    /// allocate and fill `extendedData` and `extendedBuffer`. For planar formats,
    /// one buffer will be allocated for each plane.
    ///
    /// - Warning: If frame already has been allocated, calling this function will leak memory.
    ///   In addition, undefined behavior can occur in certain cases.
    ///
    /// - Parameter align: Required buffer size alignment.
    ///   If equal to 0, alignment will be chosen automatically for the current CPU.
    ///   It is highly recommended to pass 0 here unless you know what you are doing.
    /// - Throws: AVError
    public func allocBuffer(align: Int = 0) throws {
        try throwIfFail(av_frame_get_buffer(cFramePtr, Int32(align)))
    }

    /// Set up a new reference to the data described by the source frame.
    ///
    /// Copy frame properties from `src` to this frame and create a new reference for each
    /// `AVBuffer` from `src`. If `src` is not reference counted, new buffers are allocated
    /// and the data is copied.
    ///
    /// - Warning: this frame __must__ have been either unreferenced with `unref()`, or newly
    ///   created before calling this function, or undefined behavior will occur.
    ///
    /// - Parameter src: the source frame
    /// - Throws: AVError
    public func ref(from src: AVFrame) throws {
        try throwIfFail(av_frame_ref(cFramePtr, src.cFramePtr))
    }

    /// Unreference all the buffers referenced by frame and reset the frame fields.
    public func unref() {
        av_frame_unref(cFramePtr)
    }

    /// Move everything contained in `src` to this frame and reset `src`.
    ///
    /// - Warning: This frame is not unreferenced, but directly overwritten without reading
    ///   or deallocating its contents. Call `unref()` on this frame manually before calling
    ///   this function to ensure that no memory is leaked.
    ///
    /// - Parameter src: the source frame
    public func moveRef(from src: AVFrame) {
        av_frame_move_ref(cFramePtr, src.cFramePtr)
    }

    /// Create a new frame that references the same data as this frame.
    ///
    /// This is a shortcut for `init() + ref(from:)`.
    ///
    /// - Returns: newly created `AVFrame` on success, `nil` on error.
    public func clone() -> AVFrame? {
        if let ptr = av_frame_clone(cFramePtr) {
            return AVFrame(cFramePtr: ptr)
        }
        return nil
    }

    /// Ensure that the frame data is writable, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    ///
    /// - Throws: AVError
    public func makeWritable() throws {
        try throwIfFail(av_frame_make_writable(cFramePtr))
    }

    /// Copy the frame data from `src` to this frame.
    ///
    /// This function does not allocate anything, this frame must be already initialized
    /// and allocated with the same parameters as `src`.
    ///
    /// This function only copies the frame data (i.e. the contents of the `data` /
    /// `extendedData` arrays), not any other properties.
    ///
    /// - Parameter src: the source frame
    /// - Throws: AVError
    public func copy(from src: AVFrame) throws {
        try throwIfFail(av_frame_copy(cFramePtr, src.cFramePtr))
    }

    /// Copy only "metadata" fields from `src` to this frame.
    ///
    /// Metadata for the purpose of this function are those fields that do not affect
    /// the data layout in the buffers. E.g. pts, sample rate (for audio) or sample
    /// aspect ratio (for video), but not width/height or channel layout.
    /// Side data is also copied.
    ///
    /// - Parameter src: the source frame
    /// - Throws: AVError
    public func copyProperties(from src: AVFrame) throws {
        try throwIfFail(av_frame_copy_props(cFramePtr, src.cFramePtr))
    }

    /// Get the buffer reference a given data plane is stored in.
    ///
    /// - Parameter plane: index of the data plane of interest in `extendedData`.
    /// - Returns: the buffer reference that contains the plane or `nil` if the input frame is not valid.
    public func planeBuffer(at plane: Int) -> AVBuffer? {
        if let ptr = av_frame_get_plane_buffer(cFramePtr, Int32(plane)) {
            return AVBuffer(cBufferPtr: ptr)
        }
        return nil
    }

    deinit {
        var ptr: UnsafeMutablePointer<CAVFrame>? = cFramePtr
        av_frame_free(&ptr)
    }
}

// MARK: - Video

extension AVFrame {

    /// The pixel format of the picture.
    public var pixelFormat: AVPixelFormat {
        get { AVPixelFormat(cFrame.format) }
        set { cFramePtr.pointee.format = newValue.rawValue }
    }

    /// The width of the picture, in pixels.
    public var width: Int {
        get { Int(cFrame.width) }
        set { cFramePtr.pointee.width = Int32(newValue) }
    }

    /// The height of the picture, in pixels.
    public var height: Int {
        get { Int(cFrame.height) }
        set { cFramePtr.pointee.height = Int32(newValue) }
    }

    /// A Boolean value indicating whether this frame is key frame.
    public var isKeyFrame: Bool {
        get { cFrame.key_frame == 1 }
        set { cFramePtr.pointee.key_frame = newValue ? 1 : 0 }
    }

    /// A Boolean value indicating whether this frame is interlaced or progressive frame.
    public var isInterlacedFrame: Bool {
        cFrame.interlaced_frame == 1
    }

    /// The picture type of the frame.
    public var pictureType: AVPictureType {
        get { cFrame.pict_type }
        set { cFramePtr.pointee.pict_type = newValue }
    }

    /// The sample aspect ratio for the video frame, 0/1 if unknown/unspecified.
    public var sampleAspectRatio: AVRational {
        get { cFrame.sample_aspect_ratio }
        set { cFramePtr.pointee.sample_aspect_ratio = newValue }
    }

    /// When decoding, this signals how much the picture must be delayed.
    /// ```extra_delay = repeat_pict / (2*fps)```
    public var repeatPicture: Int {
        Int(cFrame.repeat_pict)
    }

    /// The color range of the picture.
    public var colorRange: AVColorRange {
        get { cFrame.color_range }
        set { cFramePtr.pointee.color_range = newValue }
    }

    /// The color primaries of the picture.
    public var colorPrimaries: AVColorPrimaries {
        get { cFrame.color_primaries }
        set { cFramePtr.pointee.color_primaries = newValue }
    }

    /// The color transfer characteristic of the picture.
    public var colorTransferCharacteristic: AVColorTransferCharacteristic {
        get { cFrame.color_trc }
        set { cFramePtr.pointee.color_trc = newValue }
    }

    /// The color space of the picture.
    public var colorSpace: AVColorSpace {
        get { cFrame.colorspace }
        set { cFramePtr.pointee.colorspace = newValue }
    }

    /// The chroma location of the picture.
    public var chromaLocation: AVChromaLocation {
        get { cFrame.chroma_location }
        set { cFramePtr.pointee.chroma_location = newValue }
    }
}

// MARK: - Audio

extension AVFrame {

    /// The sample format of the audio data.
    public var sampleFormat: AVSampleFormat {
        get { AVSampleFormat(cFrame.format) }
        set { cFramePtr.pointee.format = newValue.rawValue }
    }

    /// The sample rate of the audio data.
    public var sampleRate: Int {
        get { Int(cFrame.sample_rate) }
        set { cFramePtr.pointee.sample_rate = Int32(newValue) }
    }

    /// The channel layout of the audio data.
    public var channelLayout: AVChannelLayout {
        get { AVChannelLayout(rawValue: cFrame.channel_layout) }
        set { cFramePtr.pointee.channel_layout = newValue.rawValue }
    }

    /// The number of audio samples (per channel) described by this frame.
    public var sampleCount: Int {
        get { Int(cFrame.nb_samples) }
        set { cFramePtr.pointee.nb_samples = Int32(newValue) }
    }

    /// The number of audio channels.
    ///
    /// - encoding: Unused.
    /// - decoding: Read by user.
    public var channelCount: Int {
        get { Int(cFrame.channels) }
        set { cFramePtr.pointee.channels = Int32(newValue) }
    }
}

extension AVFrame: AVClassSupport {
    public static let `class` = AVClass(cClassPtr: avcodec_get_frame_class())

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        fatalError("unsupported")
    }
}
