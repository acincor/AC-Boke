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
import SVProgressHUD
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
        Task {
            resetScrollView()
            
            // 2. url 缩略图的地址
            // 从磁盘加载缩略图的图像
            if let placeholderImage = try? await imageCache.retrieveImageInDiskCache(forKey: url.absoluteString) {
                setPlaceHolder(image: placeholderImage)
            }
            // 3. 异步加载大图
            imageView.kf.setImage(with: url,
                                  placeholder: nil,
                                  options: [.backgroundDecode, .retryStrategy(DelayRetryStrategy(maxRetryCount: 12, retryInterval: .seconds(1))), .fromMemoryCacheOrRefresh, .targetCache(imageCache),.diskCacheExpiration(.days(7))],
                                  progressBlock: { (current, total) -> Void in
                self.placeHolder.update(progress: CGFloat(current) / CGFloat(total))
            }) { result in
                guard let r = try? result.get() else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("图片下载失败", comment: ""))
                    return
                }
                self.placeHolder.isHidden = true
                self.setPositon(image: r.image)
            }
        }
    }
    @objc func send() {
        guard imageView.image != nil else {
            return
        }
        NetworkTools.shared.sendPortrait(image: imageView.image!) { Result, Error in
            if Result != nil {
                Task { @MainActor in
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("成功啦", comment: ""))
                }
            }
        }
        imageCache.removeImage(forKey: self.url.absoluteString)
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
    override func loadView() {
        var rect = UIScreen.main.bounds
        rect.size.width += 20
        view = UIView(frame: rect)
        setupUI()
    }
    private lazy var closeButton: UIButton = UIButton(title: NSLocalizedString("关闭", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private lazy var saveButton: UIButton = UIButton(title: NSLocalizedString("保存",comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private lazy var portraitButton: UIButton = UIButton(title: NSLocalizedString("更换头像", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private lazy var imageView = UIImageView()
    @objc func close() {
        dismiss(animated: true)
    }
    lazy var scrollView: UIScrollView = UIScrollView()
    
    /// 缩放完成后执行一次
    ///
    /// - parameter scrollView: scrollView
    /// - parameter view:       view 被缩放的视图
    /// - parameter scale:      被缩放的比例
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        // 如果缩放比例 < 1，直接关闭
        if scale < 1 {
            photoDelegate?.photoBrowserCellDidTapImage()
            
            return
        }
        
        var offsetY = (scrollView.bounds.height - view!.frame.height) * 0.5
        offsetY = offsetY < 0 ? 0 : offsetY
        
        var offsetX = (scrollView.bounds.width - view!.frame.width) * 0.5
        offsetX = offsetX < 0 ? 0 : offsetX
        
        // 设置间距
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    /// 只要缩放就会被调用
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /// 设置占位图像视图的内容
    ///
    /// - parameter image: 本地缓存的缩略图，如果缩略图下载失败，image 为 nil
    private func setPlaceHolder(image: UIImage?) {
        
        placeHolder.isHidden = false
        placeHolder.image = image
        placeHolder.sizeToFit()
        placeHolder.center = scrollView.center
    }
    
    /// 重设 scrollView 内容属性
    private func resetScrollView() {
        // 重设 imageView 的内容属性
        imageView.transform = CGAffineTransformIdentity
        
        // 重设 scrollView 的内容属性
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
    }
    
    /// 设置 imageView 的位置
    ///
    /// - parameter image: image
    /// - 长/短图
    private func setPositon(image: UIImage) {
        // 自动设置大小
        let size = self.displaySize(image: image)
        
        // 判断图片高度
        if size.height < scrollView.bounds.height {
            // 上下居中显示 - 调整 frame 的 x/y，一旦缩放，影响滚动范围
            imageView.snp.makeConstraints { make in
                make.center.equalTo(self.view.snp.center)
                make.size.equalTo(size)
            }
            
            // 内容边距 － 会调整控件位置，但是不会影响控件的滚动
            let y = (scrollView.bounds.height - size.height) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: 0, right: 0)
        } else {
            imageView.snp.makeConstraints { make in
                make.center.equalTo(self.view.snp.center)
                make.size.equalTo(size)
            }
            scrollView.contentSize = size
        }
    }
    
    /// 根据 scrollView 的宽度计算等比例缩放之后的图片尺寸
    ///
    /// - parameter image: image
    ///
    /// - returns: 缩放之后的 size
    private lazy var placeHolder: ProgressImageView = ProgressImageView()
    private func displaySize(image: UIImage) -> CGSize {
        
        let w = scrollView.bounds.width
        let h = image.size.height * w / image.size.width
        
        return CGSize(width: w, height: h)
    }
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(saveButton)
        imageView.kf.setImage(with: url,
                              placeholder: nil,
                              options: [.retryStrategy(DelayRetryStrategy(maxRetryCount: 12, retryInterval: .seconds(1))), .fromMemoryCacheOrRefresh, .targetCache(imageCache)])
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        scrollView.addSubview(placeHolder)
        // 2. 设置位置
        var rect = view.bounds
        rect.size.width -= 20
        scrollView.frame = rect
        
        // 3. 设置 scrollView 缩放
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2.0
        // 4. 添加手势识别
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
        let message = (error == nil) ? NSLocalizedString("保存成功", comment: "") : NSLocalizedString("保存失败", comment: "")
        SVProgressHUD.showInfo(withStatus: message)
    }
    var picture : UIImage?
    func reloadData() {
        if picture != nil {
            imageView.image = picture
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
