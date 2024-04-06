//
//  BKLiveController.swift
//  MHC博客
//
//  Created by mhc team on 2023/7/21.
//

import AVFoundation
import UIKit
import HaishinKit
class BKLiveController: UIViewController {
    let stopButton = UIButton(title: "结束直播", color: .white, backImageName: nil,backColor: .red)
    let startButton = UIButton(title: "开始直播", color: .white, backImageName: nil,backColor: .red)
    //MARK: - Getters and Setters
    let session = AVAudioSession.sharedInstance()
    
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
    let connection = RTMPConnection()
    lazy var stream = RTMPStream(connection: connection)
    @objc func startLive(_ sender: Any) {
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print(error)
        }

        stream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
          // print(error)
        }

        stream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), channel: 0) { _, error in
          if let error {
            print(error)
          }
        }

        let hkView = MTHKView(frame: view.bounds)
        hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        hkView.attachStream(stream)

        // add ViewController#view
        view.insertSubview(hkView, belowSubview: stopButton)

        connection.connect("rtmp://192.168.31.128:1935/live")
        stream.publish(UserAccountViewModel.sharedUserAccount.account?.uid ?? "")
    }
    @objc func stopLive(_ sender: Any) {
        DispatchQueue.main.async {
            self.stream.close()
        }
    }
}
