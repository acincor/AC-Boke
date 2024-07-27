//
//  PhotoBrowserViewController.swift
//  AC博客
//
//  Created by AC on 2022/11/29.
//

import Foundation
import Photos
import UIKit
private let PhotoBrowserCellId = "PhotoBrowserCellId"
class PhotoBrowserViewController: UIViewController, UICollectionViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.scrollToItem(at: current, at: .centeredHorizontally, animated: false)
    }
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    private class PhotoBrowserViewLayout: UICollectionViewFlowLayout {
        override func prepare() {
            super.prepare()
            itemSize = collectionView!.bounds.size
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            scrollDirection = .horizontal
            collectionView?.isPagingEnabled = true
            collectionView?.bounces = false
            collectionView?.showsHorizontalScrollIndicator = false
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count == 0 ? 1 : urls.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserCellId, for: indexPath) as! PhotoBrowserCell
        cell.backgroundColor = .black
        if urls.count == 0 {
            cell.image = self.image
        } else {
            cell.imageURL = urls[indexPath.item]
        }
        cell.photoDelegate = self
        return cell
    }
    
    private var urls: [URL]
    private var image: UIImage?
    private func prepare() {
        collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: PhotoBrowserCellId)
        collectionView.dataSource = self
    }
    private var current: IndexPath
    init(urls: [URL],image: UIImage? = nil, indexPath: IndexPath) {
        self.urls = urls
        self.image = image
        self.current = indexPath
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
    lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserViewLayout())
    private lazy var closeButton: UIButton = UIButton(title: NSLocalizedString("关闭", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private lazy var saveButton: UIButton = UIButton(title: NSLocalizedString("保存", comment: ""), fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.systemFill)
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        collectionView.frame = view.bounds
        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.left.equalTo(view.snp.left).offset(28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.right.equalTo(view.snp.right).offset(-28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        prepare()
    }
    @objc private func close() {
        dismiss(animated: true)
    }
    @objc private func save() {
        let cell = collectionView.visibleCells[0] as! PhotoBrowserCell
            guard let image = cell.imageView.image else {
                return
            }
        
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: Any?) {
        let message = (error == nil) ? NSLocalizedString("保存成功", comment: "") : NSLocalizedString("保存失败", comment: "")
        SVProgressHUD.showInfo(withStatus: message)
    }
}
extension PhotoBrowserViewController: PhotoBrowserCellDelegate {
    func photoBrowserCellDidTapImage() {
        _ = imageViewForDimiss()
        close()
    }
}
extension PhotoBrowserViewController: PhotoBrowserDismissDelegate {
    func imageViewForDimiss() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        let cell = collectionView.visibleCells[0] as! PhotoBrowserCell
        iv.image = cell.imageView.image
        iv.frame = cell.scrollView.convert(cell.imageView.frame, to: UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene}).compactMap({ $0 }).first?.windows.first)
        //UIApplication.shared.keyWindow!.addSubview(iv)
        return iv
    }
    
    func indexPathForDimiss() -> IndexPath {
        return collectionView.indexPathsForVisibleItems[0]
    }
    
    
}
