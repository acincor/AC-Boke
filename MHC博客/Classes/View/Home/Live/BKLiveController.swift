//
//  BKLiveController.swift
//  MHC博客
//
//  Created by mhc team on 2023/7/21.
//

import AVFoundation
import UIKit
import HaishinKit
import DispatchIntrospection
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
        let image = UIImage(named: "Live")
        let newImage = image?.resizableImage(withCapInsets: UIScreen.main.overscanCompensationInsets)
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
             return DispatchSerialQueue(label: "com.Mhc-inc.serialQueue")
         } else {
             return dispatch_queue_t(label: "com.Mhc-inc.serialQueue")
         }
     }
     */
    let connection = RTMPConnection()
    lazy var stream = RTMPStream(connection: connection)
    lazy var hkView = MTHKView(frame: view.bounds)
    @objc func startLive(_ sender: Any) {
        do {
            try self.session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try self.session.setActive(true)
        } catch {
            print(error)
        }
        
        self.stream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            // print(error)
        }
        
        self.stream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), channel: 0) { _, error in
            if let error {
                print(error)
            }
        }
        self.hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.hkView.attachStream(self.stream)
        self.view.insertSubview(self.hkView, belowSubview: self.stopButton)
        self.connection.connect("rtmp://mhcincapi.top:1935/live")
        self.stream.publish(UserAccountViewModel.sharedUserAccount.account?.uid ?? "")
    }
    @objc func stopLive(_ sender: Any) {
        self.stream.close()
        hkView.removeFromSuperview()
    }
}
