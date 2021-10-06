//
//  YiCropCommand.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

class YiCropCommand: NSObject, YiVideoEditorCommandProtocol {
    weak var videoData: YiVideoEditorData?
    var cropFrame: CGRect
    init(videoData: YiVideoEditorData, cropFrame: CGRect) {
        self.videoData = videoData
        self.cropFrame = cropFrame
        super.init()
    }

    func execute() {
        var instruction: AVMutableVideoCompositionInstruction?
        var layerInstruction: AVMutableVideoCompositionLayerInstruction?
        let duration = videoData?.composition?.duration
        if videoData?.videoComposition?.instructions.count == 0 {
            instruction = AVMutableVideoCompositionInstruction()
            instruction?.timeRange = CMTimeRange(start: kCMTimeZero, duration: duration ?? kCMTimeZero)
            if let videoCompositionTrack = videoData?.videoCompositionTrack {
                layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                layerInstruction?.setCropRectangle(cropFrame, at: kCMTimeZero)
                let t1 = CGAffineTransform(translationX: -1 * cropFrame.origin.x, y: -1 * cropFrame.origin.y)
                layerInstruction?.setTransform(t1, at: kCMTimeZero)
            }
        } else {
            instruction = videoData?.videoComposition?.instructions.last as? AVMutableVideoCompositionInstruction
            layerInstruction = instruction?.layerInstructions.last as? AVMutableVideoCompositionLayerInstruction
            if let duration = duration {
                var start = CGAffineTransform()
                let success = layerInstruction?.getTransformRamp(for: duration, start: &start, end: nil, timeRange: nil) ?? false
                if !success {
                    layerInstruction?.setCropRectangle(cropFrame, at: kCMTimeZero)
                    let t1 = CGAffineTransform(translationX: -1 * cropFrame.origin.x, y:  -1 * cropFrame.origin.y)
                    layerInstruction?.setTransform(t1, at: kCMTimeZero)
                } else {
                    let t1 = CGAffineTransform(translationX: -1 * cropFrame.origin.x, y:  -1 * cropFrame.origin.y)
                    let newTransform = start.concatenating(t1)
                    layerInstruction?.setTransform(newTransform, at: kCMTimeZero)
                }
            }
        }
        videoData?.videoComposition?.renderSize = cropFrame.size
        videoData?.videoSize = cropFrame.size
        if let layerInstruction = layerInstruction {
            instruction?.layerInstructions = [layerInstruction]
        }
        if let instruction = instruction {
            videoData?.videoComposition?.instructions = [instruction]
        }
    }

}
