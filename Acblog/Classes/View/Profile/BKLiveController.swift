//
//  BKLiveController.swift
//  AC博客
//
//  Created by AC on 2023/7/21.
//

import AVFoundation
import UIKit
import HaishinKit
import SRTHaishinKit
import DispatchIntrospection
import SVProgressHUD
import VideoToolbox
class BKLiveController: UIViewController {
    let stopButton = UIButton(title: NSLocalizedString("结束直播", comment: ""), color: .white, backImageName: nil,backColor: .red)
    let startButton = UIButton(title: NSLocalizedString("开始直播", comment: ""), color: .white, backImageName: nil,backColor: .red)
    //MARK: - Getters and Setters
    let session = AVAudioSession.sharedInstance()
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage.live
        let newImage = image.resizableImage(withCapInsets: UIScreen.main.overscanCompensationInsets)
        let live = UIImageView(image: newImage)
        live.frame = UIScreen.main.bounds
        view.addSubview(live)
        view.backgroundColor = .red
        for i in liveListViewModel.list {
            if i.user.uid == Int(UserAccountViewModel.sharedUserAccount.account!.uid!)! {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("你的直播已在其他设备上进行...", comment: ""))
                return
            }
        }
        title = NSLocalizedString("hi，一起直播鸭！",comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭", comment: ""), style: .plain, target: self, action: #selector(self.close))
        navigationItem.leftBarButtonItem?.tintColor = .white
        // Do any additional setup after loading the view, typically from a nib.
        startButton.layer.cornerRadius = 15
        view.addSubview(startButton)
        
        stopButton.layer.cornerRadius = 15
        view.addSubview(stopButton)
        startButton.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
        stopButton.snp.makeConstraints { make in
            make.top.equalTo(startButton.snp.bottom).offset(50)
            make.centerX.equalTo(startButton.snp.centerX)
        }
        startButton.addTarget(self, action: #selector(self.startLive(_:)), for: .touchDown)
        stopButton.addTarget(self, action: #selector(self.stopLive(_:)), for: .touchDown)
    }
    @objc func close() {
        self.dismiss(animated: true)
    }
    /*
     var sessionQueue: DispatchQueue {
     if #available(iOS 17.0, *){
     return DispatchSerialQueue(label: "com.Ac-inc.serialQueue")
     } else {
     return dispatch_queue_t(label: "com.Ac-inc.serialQueue")
     }
     }
     */
    let connection = RTMPConnection()
    lazy var stream = RTMPStream(connection: connection)
    let mixer = MediaMixer()
    lazy var hkView = MTHKView(frame: view.bounds)
    @objc func startLive(_ sender: Any) async throws {
        do {
            try self.session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try self.session.setActive(true)
        } catch {
            //print(error)
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
        
        try await self.mixer.attachAudio(AVCaptureDevice.default(for: .audio), track: 0) { audioDeviceUnit in }
        try await self.mixer.attachVideo(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), track: 0) {_ in
        }
        var audioSettings = AudioCodecSettings()
        /// Specifies the bitRate of audio output.
        audioSettings.bitRate = 64 * 1000
        /// Specifies the mixes the channels or not. Currently, it supports input sources with 4, 5, 6, and 8 channels.
        audioSettings.downmix = true
        /// Specifies the map of the output to input channels.
        audioSettings.channelMap = nil
        var videoMixerSettings = VideoMixerSettings()
        /// Specifies the image rendering mode.
        videoMixerSettings.mode = .offscreen
        /// Specifies the muted indicies whether freeze video signal or not.
        videoMixerSettings.isMuted = false
        /// Specifies the main track number.
        videoMixerSettings.mainTrack = 0

        await mixer.setVideoMixerSettings(videoMixerSettings)
        await stream.setAudioSettings(audioSettings)
        let videoSettings = VideoCodecSettings(
          videoSize: .init(width: 854, height: 480),
          bitRate: 640 * 1000, profileLevel: kVTProfileLevel_H264_Baseline_3_1 as String,
          scalingMode: .trim, bitRateMode: .average, maxKeyFrameIntervalDuration: 2,
          allowFrameReordering: nil,
          isHardwareEncoderEnabled: true
        )

        await stream.setVideoSettings(videoSettings)
        self.hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        await stream.addOutput(hkView)
        
        self.view.insertSubview(self.hkView, belowSubview: self.stopButton)
        try await self.connection.connect(localTest ? "rtmp://localhost:1935/live" : "rtmp://mhcincapi.top:1935/live")
        try await self.stream.publish(UserAccountViewModel.sharedUserAccount.account?.uid ?? "")
    }
    @objc func stopLive(_ sender: Any) async throws {
        try await self.stream.close()
        hkView.removeFromSuperview()
    }
}
