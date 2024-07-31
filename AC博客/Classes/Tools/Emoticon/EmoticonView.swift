//
//  EmoticonView.swift
//  Emoticon
//
//  Created by AC on 2022/11/10.
//

import Foundation
import UIKit
private let EmoticonViewCellId = "EmoticonViewCellId"
class EmoticonView: UIView {
    private lazy var packages = EmoticonManager.sharedManager.packages
    private var selectedEmoticonCallBack: (_ emoticon: Emoticon)->()
    private var deleteCompletion: () -> ()
    private let deleteButton = UIButton(imageName: "compose_emotion_delete", backImageName: nil)
    private lazy var maskIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    init(selectedEmoticon: @escaping(_ emoticon: Emoticon)->(),deleteCompletionCallBack: @escaping () -> ()) {
        selectedEmoticonCallBack = selectedEmoticon
        deleteCompletion = deleteCompletionCallBack
        var rect = UIScreen.main.bounds
        rect.size.height /= 4
        super.init(frame: rect)
        backgroundColor = .systemBackground
        setupUI()
    }
    private class EmoticonViewCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(emoticonButton)
            emoticonButton.backgroundColor = .systemBackground
            emoticonButton.setTitleColor(.systemOrange, for: .normal)
            emoticonButton.frame = CGRectInset(bounds, 4, 4)
            emoticonButton.titleLabel!.font = UIFont.systemFont(ofSize: 32)
            emoticonButton.isUserInteractionEnabled = false
        }
        var emoticon: Emoticon? {
            didSet {
                emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath), for: .normal)
                emoticonButton.setTitle(emoticon?.emoji, for: .normal)
            }
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        private lazy var emoticonButton: UIButton = UIButton()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
}
private extension EmoticonView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        addSubview(maskIconView)
        maskIconView.addSubview(deleteButton)
        maskIconView.isUserInteractionEnabled = true
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
        maskIconView.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.snp.right)
            make.height.equalTo(80)
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(80)
        }
        deleteButton.snp.makeConstraints { make in
            make.center.equalTo(maskIconView.snp.center)
        }
        deleteButton.addAction(UIAction(handler: { _ in
            self.deleteCompletion()
        }), for: .touchUpInside)
        prepareCollectionView()
    }
    func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.register(EmoticonViewCell.self, forCellWithReuseIdentifier: EmoticonViewCellId)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}
extension EmoticonView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonViewCellId, for: indexPath) as! EmoticonViewCell
        cell.emoticon = packages[indexPath.section].emoticons[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let em = packages[indexPath.section].emoticons[indexPath.item]
        selectedEmoticonCallBack(em)
        if indexPath.section > 0 {
            EmoticonManager.sharedManager.addFavorite(em)
        }
    }
}
