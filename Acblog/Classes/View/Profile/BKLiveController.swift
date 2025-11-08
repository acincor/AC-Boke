//
//  BKLiveController.swift
//  AC博客
//
//  Created by AC on 2023/7/21.
//
import UIKit
import HaishinKit
import RTMPHaishinKit
import AVFoundation
class BKLiveController: UIViewController {
    let stopButton = UIButton(title: NSLocalizedString("结束直播", comment: ""), color: .white, backImageName: nil,backColor: .red)
    let startButton = UIButton(title: NSLocalizedString("开始直播", comment: ""), color: .white, backImageName: nil,backColor: .red)
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    lazy var hkView = MTHKView(frame: view.bounds)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        NetworkTools.shared.isLived(finished: { Result, Error in
            guard let res = Result as? [String: Any] else {
                showInfo("加载数据错误，请稍后再试")
                return
            }
            if(res["error"] != nil) {
                showInfo("加载数据错误，请稍后再试")
                return
            }
            if(res["msg"] as! Int == 1) {
                showError("你的直播已在其他设备上进行...")
                return
            }
        })
        view.addSubview(hkView)
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
        startButton.isHidden = false
        stopButton.isHidden = true
    }
    @objc func close() {
        self.dismiss(animated: true)
    }
    // 1. 创建媒体混合器（用于管理音视频源）
    let mixer = MediaMixer()

    // 2. 创建 RTMP 连接和流对象
    let connection = RTMPConnection()
    lazy var stream = RTMPStream(connection: connection)
    @objc func startLive(_ sender: Any) {
        Task {@MainActor in
            do {
                try await mixer.attachAudio(AVCaptureDevice.default(for: .audio))
                    // 绑定摄像头（后置摄像头）
                try await mixer.attachVideo(AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .front
                ))
                await stream.addOutput(hkView) // 将流输出到预览视图
                // 将混合器输出关联到流
                await mixer.addOutput(stream)
                let host = localTest ? "rtmp://localhost:1935/live" : "rtmp://mhcincapi.top:1935/live"
                let name = UserAccountViewModel.sharedUserAccount.account?.uid ?? ""
                _ = try await connection.connect(host)
                _ = try await stream.publish(name, type: .live)
                //await mixer.startCapturing()
                await mixer.startRunning()
                startButton.isHidden = true
                stopButton.isHidden = false
            } catch {
                //print(error)
                showError(error.localizedDescription)
            }
        }
    }
    @objc func stopLive(_ sender: Any) {
        Task {@MainActor in
            _ = try await stream.close()
            //await mixer.stopCapturing()
            await mixer.stopRunning()
            startButton.isHidden = false
            stopButton.isHidden = true
        }
    }
}
