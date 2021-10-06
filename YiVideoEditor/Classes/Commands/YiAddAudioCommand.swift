//
//  YiAddAudioCommand.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

class YiAddAudioCommand: NSObject, YiVideoEditorCommandProtocol {
    weak var videoData: YiVideoEditorData?
    var audioAsset: AVAsset
    var startingAt: CGFloat
    var trackDuration: CGFloat
    init(videoData: YiVideoEditorData, audioAsset: AVAsset, startingAt: CGFloat?, trackDuration: CGFloat?) {
        self.videoData = videoData
        self.audioAsset = audioAsset
        self.startingAt = startingAt ?? 0
        self.trackDuration = trackDuration ?? CGFloat.greatestFiniteMagnitude
        super.init()
    }
    
    func execute() {
        var track: AVAssetTrack?
        if audioAsset.tracks(withMediaType: .audio).count != 0 {
            track = audioAsset.tracks(withMediaType: .audio).first
        } else {
            return
        }
        let audioCompositionTrack = videoData?.composition?.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let videoDuration = videoData?.videoCompositionTrack?.timeRange.duration
        let startTime = CMTime(seconds: Double(startingAt), preferredTimescale: videoDuration?.timescale ?? CMTimeScale(0.0))
        let trackDurationTime = CMTime(seconds: Double(trackDuration), preferredTimescale: videoDuration?.timescale ?? CMTimeScale(0.0))
        if CMTimeCompare(videoDuration ?? kCMTimeZero, startTime) == -1 {
            return
        }
        
        let availableTrackDuration = CMTimeSubtract(videoDuration ?? kCMTimeZero, CMTime(seconds: Double(startingAt), preferredTimescale: videoDuration?.timescale ?? CMTimeScale(0.0)))
        var duration: CMTime?
        if CMTimeCompare(availableTrackDuration, track?.timeRange.duration ?? kCMTimeZero) == -1 {
            duration = availableTrackDuration
        } else {
            duration = track?.timeRange.duration
        }
        
        if CMTimeCompare(trackDurationTime, duration ?? kCMTimeZero) == -1 {
            duration = trackDurationTime
        }
        let timeRange = CMTimeRange(start: kCMTimeZero, duration: duration ?? kCMTimeZero)
        do {
            if let track = track {
                try audioCompositionTrack?.insertTimeRange(timeRange, of: track, at: startTime)
            }
        } catch {
        
        }
    }

}
