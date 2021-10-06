# YiVideoEditor

[![CI Status](https://img.shields.io/travis/coderyi/YiVideoEditor.svg?style=flat)](https://travis-ci.org/coderyi/YiVideoEditor)
[![Version](https://img.shields.io/cocoapods/v/YiVideoEditor.svg?style=flat)](https://cocoapods.org/pods/YiVideoEditor)
[![License](https://img.shields.io/cocoapods/l/YiVideoEditor.svg?style=flat)](https://cocoapods.org/pods/YiVideoEditor)
[![Platform](https://img.shields.io/cocoapods/p/YiVideoEditor.svg?style=flat)](https://cocoapods.org/pods/YiVideoEditor)


YiVideoEditor is a library for rotating, cropping, adding layers (watermark) and as well as adding audio (music) to the videos.

YiVideoEditor是一个视频编辑库。支持旋转、裁剪、增加图层（水印）、增加音频。


## Installation

YiVideoEditor is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YiVideoEditor'
```

## Usage

```
let videoEditor = YiVideoEditor(videoURL: videoURL)
videoEditor.rotate(rotateDegree: .rotateDegree90)
videoEditor.crop(cropFrame: CGRect(x: 10, y: 10, width: 300, height: 200))
videoEditor.addLayer(layer: layer)
videoEditor.addAudio(asset: audioAsset, startingAt: 1, trackDuration: 3)
videoEditor.export(exportURL: exportUrl) { [weak self] (session) in
    guard let `self` = self else {
        return
    }
    if session.status == .completed {
        let vc = VideoViewController(videoUrl: exportUrl)
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.




## License

YiVideoEditor is available under the MIT license. See the LICENSE file for more info.
