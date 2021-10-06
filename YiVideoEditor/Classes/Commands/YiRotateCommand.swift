//
//  YiRotateCommand.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

class YiRotateCommand: NSObject, YiVideoEditorCommandProtocol {
    weak var videoData: YiVideoEditorData?
    
    init(videoData: YiVideoEditorData) {
        self.videoData = videoData
        super.init()
    }
    
    func execute() {
        guard let videoData = videoData else {
            return
        }
        guard var videoSize = videoData.videoComposition?.renderSize else {
            return
        }
        var instruction: AVMutableVideoCompositionInstruction?
        var layerInstruction: AVMutableVideoCompositionLayerInstruction?
        let t1 = CGAffineTransform(translationX: videoSize.height, y: 0.0)
        let t2 = t1.rotated(by: CGFloat((90.0 / 180.0 * .pi)))
        videoSize = CGSize(width: videoSize.height, height: videoSize.width)
        let duration = videoData.videoCompositionTrack?.timeRange.duration
        if videoData.videoComposition?.instructions.count == 0 {
            instruction = AVMutableVideoCompositionInstruction()
            instruction?.timeRange = CMTimeRange(start: kCMTimeZero, duration: duration ?? kCMTimeZero)
            if let videoCompositionTrack = videoData.videoCompositionTrack {
                layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                layerInstruction?.setTransform(t2, at: kCMTimeZero)
            }
        } else {
            instruction = videoData.videoComposition?.instructions.last as? AVMutableVideoCompositionInstruction
            layerInstruction = instruction?.layerInstructions.last as? AVMutableVideoCompositionLayerInstruction
            if let duration = duration {
                //UnsafeMutablePointer<CGAffineTransform>?
                var start = CGAffineTransform()
                let success = layerInstruction?.getTransformRamp(for: duration, start: &start, end: nil, timeRange: nil) ?? false
                if !success {
                    layerInstruction?.setTransform(t2, at: kCMTimeZero)
                } else {
                    let newTransform = start.concatenating(t2)
                    layerInstruction?.setTransform(newTransform, at: kCMTimeZero)
                }
            }
        }
        videoData.videoComposition?.renderSize = videoSize
        videoData.videoSize = videoSize
        if let layerInstruction = layerInstruction {
            instruction?.layerInstructions = [layerInstruction]
        }
        if let instruction = instruction {
            videoData.videoComposition?.instructions = [instruction]
        }
    }
    
}
