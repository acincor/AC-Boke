//
//  PhotoBrowserCell.swift
//  AC博客
//
//  Created by AC on 2022/11/30.
//

import Foundation
import UIKit
import Kingfisher
import SVProgressHUD
protocol PhotoBrowserCellDelegate: NSObjectProtocol {
    func photoBrowserCellDidTapImage()
}
class PhotoBrowserCell: UICollectionViewCell {
    weak var photoDelegate: PhotoBrowserCellDelegate?
    @objc private func tapImage() {
        photoDelegate?.photoBrowserCellDidTapImage()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(scrollView)
        contentView.addSubview(imageView)
        scrollView.addSubview(placeHolder)
        var rect = bounds
        rect.size.width -= 20
        scrollView.frame = rect
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2.0
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    private func displaySize(_ image: UIImage) -> CGSize{
        let w = scrollView.bounds.width
        let h = image.size.height * w / image.size.width
        return CGSize(width: w, height: h)
    }
    private func set(_ image: UIImage?) {
        placeHolder.isHidden = false
        placeHolder.image = image
        placeHolder.sizeToFit()
        placeHolder.center = scrollView.center
    }
    private func setPosition(_ image: UIImage) {
        let size = self.displaySize(image)
        if size.height < scrollView.bounds.height {
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let y = (scrollView.bounds.height - size.height) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: 0, right: 0)
            imageView.center = scrollView.center
        } else {
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            scrollView.contentSize = size
        }
    }
    private lazy var placeHolder: ProgressImageView = ProgressImageView()
    private func reset() {
        imageView.transform = CGAffineTransformIdentity
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentSize = CGSize.zero
    }
    lazy var scrollView: UIScrollView = UIScrollView()
    lazy var imageView: UIImageView = UIImageView()
    var imageURL: URL? {
        didSet {
            Task {
                guard let url = self.imageURL else {
                    return
                }
                self.reset()
                if let placeholderImage = try? await imageCache.retrieveImageInDiskCache(forKey: url.absoluteString){
                    self.set(placeholderImage)
                }
                let urlString = url.absoluteString.replacingOccurrences(of: "/thumbnail", with: "")
                if let updatedURL = URL(string: urlString) {
                    self.imageView.kf.setImage(with: updatedURL, placeholder: nil, options: [.backgroundDecode, .retryStrategy(DelayRetryStrategy(maxRetryCount: 12, retryInterval: .seconds(1))), .fromMemoryCacheOrRefresh,.targetCache(imageCache),.diskCacheExpiration(.days(7))]) { receivedSize, totalSize in
                        self.placeHolder.update(progress: CGFloat(receivedSize) / CGFloat(totalSize))
                    } completionHandler: { result in
                        guard let r = try? result.get() else {
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("图片下载失败", comment: ""))
                            return
                        }
                        self.placeHolder.isHidden = true
                        self.setPosition(r.image)
                    }
                }
            }
        }
    }
    var image: UIImage? {
        didSet {
            guard let image = image else {
                return
            }
            reset()
            imageView.image = image
            self.placeHolder.isHidden = true
            
            // 设置图像视图位置
            self.setPosition(image)
        }
    }
}
extension PhotoBrowserCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
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
}
