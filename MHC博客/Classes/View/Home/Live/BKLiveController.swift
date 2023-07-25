//
//  BKLiveController.swift
//  MHC博客
//
//  Created by mhc team on 2023/7/21.
//

import Foundation
import UIKit
class LiveController: UIViewController {
    //MARK: - Getters and Setters
    lazy var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .low3, outputImageOrientation: .portrait)
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        
        session?.preView = self.view
        return session!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view, typically from a nib.
        let startButton = UIButton(title: "开始直播", color: .white, backImageName: nil,backColor: .red)
        startButton.layer.cornerRadius = 15
        view.addSubview(startButton)
        let stopButton = UIButton(title: "结束直播", color: .white, backImageName: nil,backColor: .red)
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
    
    @objc func startLive(_ sender: Any) {
        let stream = LFLiveStreamInfo()
        stream.url = "rtmp://mhc.lmyz6.cn:1935/live/\(UserAccountViewModel.sharedUserAccount.account!.uid!)";
        //stream.url = "rtmp://mhc.lmyz6.cn:1935/live?uid=888505392646/Mhc-inc";
        //stream.streamId = UserAccountViewModel.sharedUserAccount.account?.user
        session.startLive(stream)
        session.running = true
    }
    @objc func stopLive(_ sender: Any) {
        session.stopLive()
    }
}
