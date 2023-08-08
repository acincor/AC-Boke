//
//  StatusPictureView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/12.
//

import UIKit

let ProfilePictureViewItemMargin: CGFloat = 8
let ProfilePictureCellId = "ProfilePictureCellId"
class ProfilePictureView:UICollectionView {
    var viewModel: URL
    init(viewModel: URL) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = ProfilePictureViewItemMargin
        layout.minimumInteritemSpacing = ProfilePictureViewItemMargin
        self.viewModel = viewModel
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        delegate = self
        backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        dataSource = self
        register(ProfilePictureViewCell.self, forCellWithReuseIdentifier: ProfilePictureCellId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ProfilePictureView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePictureCellId, for: indexPath) as! ProfilePictureViewCell
        cell.imageURL = viewModel
        return cell
    }
}
class ProfilePictureViewCell: UICollectionViewCell {
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
extension ProfilePictureView:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("单击照片\(indexPath) \(viewModel?.thumbnailUrls)")
        let userInfo = [WBProfileSelectedPhotoIndexPathKey: indexPath, WBProfileSelectedPhotoURLsKey: [viewModel]] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name(WBProfileSelectedPhotoNotification), object: self, userInfo: userInfo)
        //photoBrowserPresentFromRect(indexPath: indexPath)
        photoBrowserPresentToRect(indexPath: indexPath)
    }
}
extension ProfilePictureView: ProfileBrowserPresentDelegate{
    func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect {
        let cell = self.cellForItem(at: indexPath)!
        let rect = self.convert(cell.frame, to: UIApplication.shared.keyWindow!)
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
        iv.sd_setImage(with: viewModel)
        return iv
    }
    func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect {
        let key = viewModel.absoluteString
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
