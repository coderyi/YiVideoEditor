//
//  YiVideoEditorData.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

class YiVideoEditorData: NSObject {
    var asset: AVAsset
    var composition: AVMutableComposition?
    var assetVideoTrack: AVAssetTrack?
    var assetAudioTrack: AVAssetTrack?
    var videoComposition: AVMutableVideoComposition?
    var videoCompositionTrack: AVMutableCompositionTrack?
    var audioCompositionTrack: AVMutableCompositionTrack?
    var videoSize: CGSize = .zero
    init(asset: AVAsset) {
        self.asset = asset
        super.init()
        self.loadAsset(asset: asset)
    }
    
    func loadAsset(asset: AVAsset) -> Void {
        if asset.tracks(withMediaType: .video).count != 0 {
            assetVideoTrack = asset.tracks(withMediaType: .video).first
        }
        if asset.tracks(withMediaType: .audio).count != 0 {
            assetAudioTrack = asset.tracks(withMediaType: .audio).first
        }
        videoSize = assetVideoTrack?.naturalSize ?? .zero
        composition = AVMutableComposition()
        videoComposition = AVMutableVideoComposition()
        videoComposition?.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition?.renderSize = videoSize
        let insertionPoint: CMTime = kCMTimeZero
        if let assetVideoTrack = assetVideoTrack {
            videoCompositionTrack = composition?.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetVideoTrack, at: insertionPoint)
            } catch {
            }
        }
        if let assetAudioTrack = assetAudioTrack {
            audioCompositionTrack = composition?.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try audioCompositionTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: asset.duration), of: assetAudioTrack, at: insertionPoint)
            } catch {
            }
        }

    }
}
