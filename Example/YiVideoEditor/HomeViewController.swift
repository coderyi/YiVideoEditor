//
//  HomeViewController.swift
//  YiVideoEditor_Example
//
//  Created by coderyi on 2021/10/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import YiVideoEditor

class HomeViewController: UIViewController {
    var camera: LLSimpleCamera?
    lazy var snapButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 80.0 / 2.0
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        return button
    }()
    
    lazy var snapButtonBgView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.layer.cornerRadius = 80.0 / 2.0
        effectView.layer.masksToBounds = true
        return effectView
    }()
    
    var discLayer: CAShapeLayer = {
        let radius = 6
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(red: 208.0 / 255.0, green: 2.0 / 255.0, blue: 27.0 / 255.0, alpha: 1).cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
        layer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)).cgPath
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        let screenRect = UIScreen.main.bounds
        camera = LLSimpleCamera(quality: AVCaptureSession.Preset.hd1280x720.rawValue, position: CameraPositionBack, videoEnabled: true)
        camera?.attach(to: self, withFrame: CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height))
        camera?.onDeviceChange = { (camera, device) in
            
        }
        camera?.onError = { (camera, error) in
            
        }
        
        let snapButtonSize = CGSize(width: 80, height: 80)
        view.addSubview(snapButtonBgView)
        snapButtonBgView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 80) / 2, y: UIScreen.main.bounds.size.height - 80 - 20, width: 80, height: 80)
        snapButtonBgView.contentView.addSubview(snapButton)
        snapButton.addTarget(self, action: #selector(snapButtonTouchDown), for: .touchDown)
        snapButton.addTarget(self, action: #selector(snapButtonTouchUpInside), for: .touchUpInside)
        snapButton.addTarget(self, action: #selector(snapButtonTouchUpOutside), for: .touchUpOutside)
        snapButton.frame = snapButtonBgView.bounds
        discLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        discLayer.position = CGPoint(x: snapButtonSize.width / 2.0, y: snapButtonSize.height / 2.0)
        discLayer.isHidden = true
        snapButtonBgView.layer.addSublayer(discLayer)
        
    }

    @objc func snapButtonTouchDown() -> Void {
        startCapturing()
    }
    @objc func snapButtonTouchUpInside() -> Void {
        stopCapturing()
    }
    @objc func snapButtonTouchUpOutside() -> Void {
        stopCapturing()
    }
    
    func startCapturing() {
        let filePath:String = NSHomeDirectory() + "/Documents/test1.mov"
        let outputURL = URL(fileURLWithPath: filePath)
        camera?.startRecording(withOutputUrl: outputURL)
        animateButton()
    }
    
    func stopCapturing() {
        camera?.stopRecording({ [weak self] (camera, outputFileUrl, error) in
            guard let `self` = self else {
                return
            }
            if let outputFileUrl = outputFileUrl {
                self.editVideo(videoURL: outputFileUrl)
            }
        })
        snapButton.layer.borderColor = UIColor.white.cgColor
        discLayer.isHidden = true
        let layer = discLayer.presentation()
        layer?.removeAllAnimations()
    }

    func editVideo(videoURL: URL) -> Void {
        let filePath:String = NSHomeDirectory() + "/Documents/output.mov"
        let exportUrl = URL(fileURLWithPath: filePath)

        guard let audioUrl = Bundle.main.url(forResource: "applause-01", withExtension: "mp3") else {
            return
        }
        
        let audioAsset = AVURLAsset(url: audioUrl)
        let layer = createVideoLayer()
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
    }
    
    func createVideoLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = UIColor.red.cgColor
        layer.frame = CGRect(x: 10, y: 10, width: 100, height: 50)
        return layer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera?.start()
    }
    
    func animateButton() -> Void {
        snapButton.layer.borderColor = UIColor(red: 208.0 / 255.0, green: 2.0 / 255.0, blue: 27.0 / 255.0, alpha: 1).cgColor

        discLayer.isHidden = false
        let newRadius = 40
        let newBounds = CGRect(x: 0, y: 0, width: 2 * newRadius, height: 2 * newRadius)
        let newPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 2 * newRadius, height: 2 * newRadius))
        let pathAnim = CABasicAnimation(keyPath: "path")
        pathAnim.toValue = newPath.cgPath
        let boundsAnim = CABasicAnimation(keyPath: "bounds")
        boundsAnim.toValue = newBounds
        
        let anims = CAAnimationGroup()
        anims.animations = [boundsAnim, pathAnim]
        anims.isRemovedOnCompletion = false
        anims.duration = 10.0
        anims.fillMode = kCAFillModeForwards
        discLayer.add(anims, forKey: nil)
            
        UIView.animate(withDuration: 0.25) {
            self.snapButtonBgView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { (finished) in
            UIView.animate(withDuration: 0.3) {
                self.snapButtonBgView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } completion: { (finished) in
                UIView.animate(withDuration: 0.3) {
                    self.snapButtonBgView.transform = CGAffineTransform.identity
                } completion: { (finished) in
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
