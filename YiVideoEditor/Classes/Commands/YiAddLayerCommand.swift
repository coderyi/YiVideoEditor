//
//  YiAddLayerCommand.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

class YiAddLayerCommand: NSObject, YiVideoEditorCommandProtocol {
    weak var videoData: YiVideoEditorData?
    var layer: CALayer
    init(videoData: YiVideoEditorData, layer: CALayer) {
        self.videoData = videoData
        self.layer = layer
        super.init()
    }
    
    func execute() {
        guard let videoData = videoData else {
            return
        }
        let videoSize = videoData.videoSize
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(layer)
        
        let duration = videoData.composition?.duration
        if videoData.videoComposition?.instructions.count == 0 {
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: duration ?? kCMTimeZero)
            if let videoCompositionTrack = videoData.videoCompositionTrack {
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                instruction.layerInstructions = [layerInstruction]
                videoData.videoComposition?.instructions = [instruction]
            }
        }
        videoData.videoComposition?.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    }

}
