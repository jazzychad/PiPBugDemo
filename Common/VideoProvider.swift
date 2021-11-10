//
//  VideoProvider.swift
//  PiPBugDemo
//
//  Created by Chad Etzel on 11/10/21.
//

import Foundation
import AVFoundation

class VideoProvider: NSObject {

    var bufferDisplayLayer: AVSampleBufferDisplayLayer = AVSampleBufferDisplayLayer()

    private var timer: Timer!
    private var imageIndex: Int = 0
    private var filenames: [String] = ["1", "2", "3", "4", "5"]


    func start() {
        let timerBlock: ((Timer) -> Void) = { timer in
            guard let data = self.getFrameJPEGData() else { return }
            let frameBuffer = self.sampleBufferFromJPEGData(data)
            if let buffer = frameBuffer {
                self.bufferDisplayLayer.enqueue(buffer)
            } else {
                print("missing frame")
            }
        }

        timer = Timer(timeInterval: 0.3, repeats: true, block: timerBlock)
        RunLoop.main.add(timer, forMode: .default)
    }

    func stop() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }

    func isRunning() -> Bool {
        return timer != nil
    }

    func getFrameJPEGData() -> Data? {

        let filename = filenames[imageIndex]
        imageIndex = (imageIndex + 1) % filenames.count

        if let path = Bundle.main.path(forResource: filename, ofType: "jpg") {
            if let jpegData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return jpegData
            }
            return nil
        }
        return nil
    }


    func sampleBufferFromJPEGData(_ jpegData: Data) -> CMSampleBuffer? {

        let rawPixelSize = CGSize(width: 640, height: 480)
        var format: CMFormatDescription? = nil
        let _ = CMVideoFormatDescriptionCreate(allocator: kCFAllocatorDefault, codecType: kCMVideoCodecType_JPEG, width: Int32(rawPixelSize.width), height: Int32(rawPixelSize.height), extensions: nil, formatDescriptionOut: &format)

        do {
            let cmBlockBuffer = try jpegData.toCMBlockBuffer()

            var size = jpegData.count

            var sampleBuffer: CMSampleBuffer? = nil
            let nowTime = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 60)
            let _1_60_s = CMTime(value: 1, timescale: 60) //CMTime(seconds: 1.0, preferredTimescale: 30)
            var timingInfo: CMSampleTimingInfo = CMSampleTimingInfo(duration: _1_60_s, presentationTimeStamp: nowTime, decodeTimeStamp: .invalid)

            let _ = CMSampleBufferCreateReady(allocator: kCFAllocatorDefault, dataBuffer: cmBlockBuffer, formatDescription: format, sampleCount: 1, sampleTimingEntryCount: 1, sampleTimingArray: &timingInfo, sampleSizeEntryCount: 1, sampleSizeArray: &size, sampleBufferOut: &sampleBuffer)
            if sampleBuffer != nil {
                //print("sending buffer to displayBufferLayer")
                //self.bufferDisplayLayer.enqueue(sampleBuffer!)
                return sampleBuffer
            } else {
                print("sampleBuffer is nil")
                return nil
            }
        } catch {
            print("error ugh ", error)
            return nil
        }
    }

}


private func freeBlock(_ refCon: UnsafeMutableRawPointer?, doomedMemoryBlock: UnsafeMutableRawPointer, sizeInBytes: Int) -> Void {
    let unmanagedData = Unmanaged<NSData>.fromOpaque(refCon!)
    unmanagedData.release()
}

enum CMEncodingError: Error {
    case cmBlockCreationFailed
}

extension Data {

    func toCMBlockBuffer() throws -> CMBlockBuffer {
        // This block source is a manually retained pointer to our data instance.
        // The passed FreeBlock function manually releases it when the block buffer gets deallocated.
        let data = NSMutableData(data: self)
        var source = CMBlockBufferCustomBlockSource()
        source.refCon = Unmanaged.passRetained(data).toOpaque()
        source.FreeBlock = freeBlock

        var blockBuffer: CMBlockBuffer?
        let result = CMBlockBufferCreateWithMemoryBlock(
            allocator: kCFAllocatorDefault,
            memoryBlock: data.mutableBytes,
            blockLength: data.length,
            blockAllocator: kCFAllocatorNull,
            customBlockSource: &source,
            offsetToData: 0,
            dataLength: data.length,
            flags: 0,
            blockBufferOut: &blockBuffer)
        if OSStatus(result) != kCMBlockBufferNoErr {
            throw CMEncodingError.cmBlockCreationFailed
        }

        guard let buffer = blockBuffer else {
            throw CMEncodingError.cmBlockCreationFailed
        }

        assert(CMBlockBufferGetDataLength(buffer) == data.length)
        return buffer
    }
}
