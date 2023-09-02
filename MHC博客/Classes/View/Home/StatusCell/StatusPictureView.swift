//
//  StatusPictureView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/12.
//

import UIKit

let StatusPictureViewItemMargin: CGFloat = 8
let StatusPictureCellId = "StatusPictureCellId"
class StatusPictureView:UICollectionView {
    var viewModel: StatusViewModel? {
        didSet {
            sizeToFit()
            reloadData()
        }
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return calcViewSize()
    }
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = StatusPictureViewItemMargin
        layout.minimumInteritemSpacing = StatusPictureViewItemMargin
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        delegate = self
        backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        dataSource = self
        register(StatusPictureViewCell.self, forCellWithReuseIdentifier: StatusPictureCellId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension StatusPictureView {
    private func calcViewSize() -> CGSize {
        let rowCount: CGFloat = 3
        let maxWidth = UIScreen.main.bounds.width - 2 * StatusCellMargin
        let itemWidth = (maxWidth - 2 * StatusPictureViewItemMargin) / rowCount
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        let count = viewModel?.thumbnailUrls?.count ?? 0
        if count == 0 {
            return CGSizeZero
        }
        if count == 1 {
            var size = CGSize(width: 150, height: 120)
            if let key = viewModel?.thumbnailUrls?.first?.absoluteString {
                let image = SDImageCache.shared.imageFromDiskCache(forKey: key)
                size = image?.size ?? CGSizeZero
            }
            size.width = size.width < 40 ? 40 : size.width
            if size.width > 300 {
                let w: CGFloat = 300
                let h = size.height * w / size.width
                size = CGSize(width: w, height: h)
            }
            layout.itemSize = size
            return size
        }
        if count == 4 {
            let w = 2 * itemWidth + StatusPictureViewItemMargin
            return CGSize(width: w, height: w)
        }
        let row = CGFloat((count - 1) / Int(rowCount) + 1)
        let h = row * itemWidth + (row - 1) * StatusPictureViewItemMargin + 1
        let w = rowCount * itemWidth + (rowCount - 1) * StatusPictureViewItemMargin + 1
        return CGSize(width: w, height: h)
    }
}
extension StatusPictureView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.thumbnailUrls?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusPictureCellId, for: indexPath) as! StatusPictureViewCell
        cell.imageURL = viewModel!.thumbnailUrls![indexPath.item]
        return cell
    }
}
class StatusPictureViewCell: UICollectionViewCell {
    var imageURL: URL? {
        didSet {
            iconView.sd_setImage(with: imageURL, placeholderImage: nil, options: [SDWebImageOptions.retryFailed,SDWebImageOptions.refreshCached])
            let ext = ((imageURL?.absoluteString ?? "") as NSString).pathExtension.lowercased()
            gifIconView.isHidden = (ext != "gif")
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(iconView)
        iconView.addSubview(gifIconView)
        iconView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.edges)
        }
        gifIconView.snp.makeConstraints { make in
            make.right.equalTo(iconView.snp.right)
            make.bottom.equalTo(iconView.snp.bottom)
        }
    }
    private lazy var iconView: UIImageView = UIImageView()
    private lazy var gifIconView: UIImageView = UIImageView(imageName: "timeline_image_gif")
}
extension StatusPictureView:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("单击照片\(indexPath) \(viewModel?.thumbnailUrls)")
        let userInfo = [WBStatusSelectedPhotoIndexPathKey: indexPath, WBStatusSelectedPhotoURLsKey: viewModel!.thumbnailUrls!] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name(WBStatusSelectedPhotoNotification), object: self, userInfo: userInfo)
        //photoBrowserPresentFromRect(indexPath: indexPath)
        _ = photoBrowserPresentToRect(indexPath: indexPath)
    }
}
extension StatusPictureView: PhotoBrowserPresentDelegate{
    func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect {
        let cell = self.cellForItem(at: indexPath)!
        let rect = self.convert(cell.frame, to: UIApplication.shared.windows.first { $0.isKeyWindow })
        //let v = imageViewForPresent(indexPath: indexPath)
        //v.backgroundColor = .red
        //v.frame = rect
        //UIApplication.shared.keyWindow?.addSubview(v)
        return rect
    }
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        if let url = viewModel?.thumbnailUrls?[indexPath.item] {
            iv.sd_setImage(with: url)
        }
        return iv
    }
    func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect {
        guard let key = viewModel?.thumbnailUrls?[indexPath.item].absoluteString else {
            return CGRectZero
        }
        guard let image = SDImageCache.shared.imageFromDiskCache(forKey: key) else {
            return CGRectZero
        }
        let w = UIScreen.main.bounds.width
        let h = image.size.height * w / image.size.width
        let screenHeight = UIScreen.main.bounds.height
        var y: CGFloat = 0
        if h < screenHeight {
            y = (screenHeight - h) * 0.5
        }
        let rect = CGRect(x: 0, y: y, width: w, height: h)
        return rect
    }
}
