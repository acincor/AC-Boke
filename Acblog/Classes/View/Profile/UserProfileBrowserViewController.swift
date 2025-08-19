//
//  UserProfileBrowserViewController.swift
//  AC博客
//
//  Created by AC on 2022/11/29.
//

import Foundation
import Photos
import UIKit
import Kingfisher
class UserProfileBrowserViewController: UIViewController, UIScrollViewDelegate{
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    weak var photoDelegate: PhotoBrowserCellDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. 恢复 scrollView
        setupUI()
        setPlaceHolder()
        // 3. 异步加载大图
        imageView.kf.setImage(with: url,
                              placeholder: nil,
                              progressBlock: { (current, total) -> Void in
            self.placeHolder.update(progress: CGFloat(current) / CGFloat(total))
        }) { result in
            guard let r = try? result.get() else {
                showError("图片下载失败")
                return
            }
            self.placeHolder.isHidden = true
            self.setPosition(image: r.image)
        }
    }
    @objc func send() {
        guard imageView.image != nil else {
            return
        }
        NetworkTools.shared.sendPortrait(image: imageView.image!) { Result, Error in
            if Result != nil {
                showInfo("成功啦")
            }
        }
        portraitButton.removeFromSuperview()
        portraitButton = UIButton(title: NSLocalizedString("更换头像", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: .systemFill)
        portraitButton.addTarget(self, action: #selector(self.sendPortrait), for: .touchUpInside)
        view.addSubview(portraitButton)
        portraitButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.left.equalTo(view.snp.left).offset(28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
    }
    var url: URL
    var style: User
    init(url: URL,style: User) {
        self.url = url
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var closeButton: UIButton = UIButton(title: NSLocalizedString("关闭", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private lazy var saveButton: UIButton = UIButton(title: NSLocalizedString("保存",comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private lazy var portraitButton: UIButton = UIButton(title: NSLocalizedString("更换头像", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private lazy var imageView = UIImageView()
    @objc func close() {
        dismiss(animated: true)
    }
    /// 设置占位图像视图的内容
    ///
    /// - parameter image: 本地缓存的缩略图，如果缩略图下载失败，image 为 nil
    private func setPlaceHolder() {
        placeHolder.isHidden = false
        placeHolder.image = .avatarDefaultBig
        placeHolder.sizeToFit()
        placeHolder.center = view.center
    }
    
    /// 设置 imageView 的位置
    ///
    /// - parameter image: image
    /// - 长/短图
    private func setPosition(image: UIImage) {
        // 自动设置大小
        let size = self.displaySize(image: image)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(size)
            make.center.equalTo(self.view.snp.center)
        }
    }
    
    /// 根据 scrollView 的宽度计算等比例缩放之后的图片尺寸
    ///
    /// - parameter image: image
    ///
    /// - returns: 缩放之后的 size
    private lazy var placeHolder: ProgressImageView = ProgressImageView()
    private func displaySize(image: UIImage) -> CGSize {
        
        let w = view.bounds.width
        let h = image.size.height * w / image.size.width
        
        return CGSize(width: w, height: h)
    }
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(saveButton)
        view.addSubview(imageView)
        view.addSubview(placeHolder)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        if style == .Me {
            view.addSubview(portraitButton)
            portraitButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.snp.bottom).offset(-8)
                make.left.equalTo(view.snp.left).offset(28)
                make.size.equalTo(CGSize(width: 100, height: 36))
            }
            portraitButton.addTarget(self, action: #selector(sendPortrait), for: .touchUpInside)
        } else {
            view.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.snp.bottom).offset(-8)
                make.left.equalTo(view.snp.left).offset(28)
                make.size.equalTo(CGSize(width: 100, height: 36))
            }
            closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        }
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.right.equalTo(view.snp.right).offset(-28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    }
    @objc private func sendPortrait() {
        guard imageView.image != nil else {
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc private func save() {
        
        guard let image = imageView.image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: Any?) {
        let message = (error == nil) ? "保存成功" : "保存失败"
        showInfo(message)
    }
    var picture : UIImage?
    func reloadData() {
        if picture != nil {
            imageView.image = picture
            setPosition(image: picture!)
            portraitButton.removeFromSuperview()
            portraitButton = UIButton(title: NSLocalizedString("完成", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: .systemFill)
            portraitButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
            view.addSubview(portraitButton)
            portraitButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.snp.bottom).offset(-8)
                make.left.equalTo(view.snp.left).offset(28)
                make.size.equalTo(CGSize(width: 100, height: 36))
            }
        }
    }
}
extension UserProfileBrowserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true,completion: nil)
        picture = image
        reloadData()
    }
}
