//
//  BKLiveController.swift
//  MHC博客
//
//  Created by mhc team on 2023/7/21.
//

import Foundation
import UIKit
class BKLiveController: UIViewController {
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
        let image = UIImage(named: "Live")
        let newImage = image?.resizableImage(withCapInsets: UIScreen.main.overscanCompensationInsets)
        let live = UIImageView(image: newImage)
        live.frame = UIScreen.main.bounds
        view.addSubview(live)
        view.backgroundColor = .red
        for i in liveListViewModel.liveList {
            if i.user.uid == Int(UserAccountViewModel.sharedUserAccount.account!.uid!)! {
                SVProgressHUD.showInfo(withStatus: "你的直播已在其他设备上进行...")
                return
            }
        }
        title = "hi，一起直播鸭！"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(self.close))
        navigationItem.leftBarButtonItem?.tintColor = .white
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
    @objc func close() {
        self.dismiss(animated: true)
    }
    @objc func startLive(_ sender: Any) {
        let stream = LFLiveStreamInfo()
        stream.url = "rtmp://192.168.31.128:1935/live/\(UserAccountViewModel.sharedUserAccount.account!.uid!)";
        //stream.url = "rtmp://localhost:1935/live?uid=888505392646/Mhc-inc";
        //stream.streamId = UserAccountViewModel.sharedUserAccount.account?.user
        session.startLive(stream)
        session.running = true
    }
    @objc func stopLive(_ sender: Any) {
        session.stopLive()
    }
}
