// LineBasedFrameDecoder.swift
//

import NIO

final class LineBasedFrameDecoder: ByteToMessageDecoder, ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    
    var cumulationBuffer: ByteBuffer?
    
    // keep track of the last scan offset from the buffer's reader index (if we didn't find the delimiter)
    private var lastScanOffset = 0
    private var handledLeftovers = false
    
    init() { }
    
    
    // Both ByteToMessageDeocoder & ChannelInboundHandler define default implementation, causing ambiguity
    // Redefining it here seems to be required to remove ambiguity for the compiler
    @inlinable
    func wrapInboundOut(_ value: InboundOut) -> NIOAny {
        .init(value)
    }
    
    func decode(context ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        if let frame = try findNextFrame(buffer: &buffer) {
            ctx.fireChannelRead(wrapInboundOut(frame))
            return .continue
            
        } else {
            return .needMoreData
        }
    }

    private func findNextFrame(buffer: inout ByteBuffer) throws -> ByteBuffer? {
        let view = buffer.readableBytesView.dropFirst(lastScanOffset)
        // look for the delimiter
        if let delimiterIndex = view.firstIndex(of: 0x0A) { // '\n'
            let length = delimiterIndex - buffer.readerIndex
            let dropCarriageReturn = delimiterIndex > view.startIndex && view[delimiterIndex - 1] == 0x0D // '\r'
            let buff = buffer.readSlice(length: dropCarriageReturn ? length - 1 : length)
            // drop the delimiter (and trailing carriage return if appicable)
            buffer.moveReaderIndex(forwardBy: dropCarriageReturn ? 2 : 1)
            
            // reset the last scan start index since we found a line
            lastScanOffset = 0
            
            return buff
        }
        
        // next scan we start where we stopped
        lastScanOffset = buffer.readableBytes
        return nil
    }
    
    func handlerRemoved(context ctx: ChannelHandlerContext) {
        handleLeftOverBytes(context: ctx)
    }
    
    func channelInactive(context ctx: ChannelHandlerContext) {
        handleLeftOverBytes(context: ctx)
    }
    
    private func handleLeftOverBytes(context ctx: ChannelHandlerContext) {
        if let buffer = cumulationBuffer, buffer.readableBytes > 0 && !handledLeftovers {
            handledLeftovers = true
            ctx.fireErrorCaught(LeftOverBytesError(leftOverBytes: buffer))
            
        }
        
    }
    
}

struct LeftOverBytesError: Error, Equatable {
    let leftOverBytes: ByteBuffer
    
}
