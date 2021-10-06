//
//  VideoViewController.swift
//  YiVideoEditor_Example
//
//  Created by coderyi on 2021/10/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
    
    var videoUrl: URL?
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    
    convenience init(videoUrl: URL) {
        self.init(nibName: nil, bundle: nil)
        self.videoUrl = videoUrl
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        if let videoUrl = videoUrl {
            avPlayer = AVPlayer(url: videoUrl)
            avPlayer?.actionAtItemEnd = .none
            avPlayerLayer = AVPlayerLayer(player: avPlayer)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
            let screenRect = UIScreen.main.bounds
            avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
            if let avPlayerLayer = avPlayerLayer {
                view.layer.addSublayer(avPlayerLayer)
            }
        }
        
        view.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        cancelButton.frame = CGRect(x: 0, y: 20, width: 44, height: 44)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer?.play()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p = notification.object as? AVPlayerItem
        p?.seek(to: kCMTimeZero)
    }
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let cancelImage = UIImage(named: "cancel.png")
        button.tintColor = .white
        button.setImage(cancelImage, for: .normal)
        button.imageView?.clipsToBounds = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 1.0
        button.clipsToBounds = false
        return button
    }()

    @objc func cancelButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
