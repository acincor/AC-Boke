//
//  PhotoBrowserViewController.swift
//  MHC微博
//
//  Created by mhc team on 2022/11/29.
//

import Foundation
import Photos
import UIKit
private let UserProfileBrowserCellId = "UserProfileBrowserCellId"
class UserProfileBrowserViewController: UIViewController, UICollectionViewDataSource{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.scrollToItem(at: current, at: .centeredHorizontally, animated: false)
    }
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
        return urls.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileBrowserCellId, for: indexPath) as! ProfileBrowserCell
        cell.backgroundColor = .black
        if picture != nil {
            cell.imageView.image = picture
            portraitButton.removeFromSuperview()
            portraitButton = UIButton(title: "完成", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkText)
                portraitButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
            view.addSubview(portraitButton)
            portraitButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.snp.bottom).offset(-8)
                make.left.equalTo(view.snp.left).offset(28)
                make.size.equalTo(CGSize(width: 100, height: 36))
            }
        } else {
            cell.imageURL = urls[indexPath.item]
        }
        cell.photoDelegate = self
        return cell
    }
    @objc func send() {
        let cell = collectionView.visibleCells[0] as! ProfileBrowserCell
        guard let image = cell.imageView.image else {
            return
        }
        NetworkTools.shared.sendPortrait(image: image) { Result, Error in
            if Result != nil {
                SVProgressHUD.showInfo(withStatus: "成功啦")
                SDImageCache.shared.clearDisk()
            }
        }
    }
    private var urls: [URL]
    private func prepare() {
        collectionView.register(ProfileBrowserCell.self, forCellWithReuseIdentifier: UserProfileBrowserCellId)
        collectionView.dataSource = self
    }
    private var current: IndexPath
    init(urls: [URL], indexPath: IndexPath) {
        self.urls = urls
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
    private lazy var saveButton: UIButton = UIButton(title: "保存", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkText)
    private lazy var portraitButton: UIButton = UIButton(title: "更换头像", fontSize: 14, color: UIColor.white, imageName: nil, backColor: UIColor.darkText)
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(portraitButton)
        view.addSubview(saveButton)
        collectionView.frame = view.bounds
        portraitButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.left.equalTo(view.snp.left).offset(28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.right.equalTo(view.snp.right).offset(-28)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        portraitButton.addTarget(self, action: #selector(sendPortrait), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        prepare()
    }
    @objc private func sendPortrait() {
        let cell = collectionView.visibleCells[0] as! ProfileBrowserCell
        guard let image = cell.imageView.image else {
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc private func save() {
        let cell = collectionView.visibleCells[0] as! ProfileBrowserCell
            guard let image = cell.imageView.image else {
                return
            }
        
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: Any?) {
        let message = (error == nil) ? "保存成功" : "保存失败"
        SVProgressHUD.showInfo(withStatus: message)
    }
    var picture : UIImage?
}
extension UserProfileBrowserViewController: ProfileBrowserCellDelegate {
    func profileBrowserCellDidTapImage() {
        imageViewForDimiss()
        self.dismiss(animated: true)
    }
}
extension UserProfileBrowserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true,completion: nil)
        picture = image
        collectionView.reloadData()
    }
}
extension UserProfileBrowserViewController: ProfileBrowserDismissDelegate {
    func imageViewForDimiss() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        let cell = collectionView.visibleCells[0] as! ProfileBrowserCell
        iv.image = cell.imageView.image
        iv.frame = cell.scrollView.convert(cell.imageView.frame, to: UIApplication.shared.keyWindow!)
        //UIApplication.shared.keyWindow!.addSubview(iv)
        return iv
    }
    
    func indexPathForDimiss() -> IndexPath {
        return collectionView.indexPathsForVisibleItems[0]
    }
    
    
}
