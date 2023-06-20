//
//  EmoticonView.swift
//  Emoticon
//
//  Created by mhc team on 2022/11/10.
//

import Foundation
import UIKit
private let EmoticonViewCellId = "EmoticonViewCellId"
class EmoticonView: UIView {
    private lazy var packages = EmoticonManager.sharedManager.packages
    private var selectedEmoticonCallBack: (_ emoticon: Emoticon)->()
    init(selectedEmoticon: @escaping(_ emoticon: Emoticon)->()) {
        selectedEmoticonCallBack = selectedEmoticon
        var rect = UIScreen.main.bounds
        rect.size.height = 226
        super.init(frame: rect)
        backgroundColor = .white
        setupUI()
        let indexPath = IndexPath(item: 0, section: 1)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }
    private class EmoticonViewCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(emoticonButton)
            emoticonButton.backgroundColor = .white
            emoticonButton.setTitleColor(.black, for: .normal)
            emoticonButton.frame = CGRectInset(bounds, 4, 4)
            emoticonButton.titleLabel!.font = UIFont.systemFont(ofSize: 32)
            emoticonButton.isUserInteractionEnabled = false
        }
        var emoticon: Emoticon? {
            didSet {
                emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath), for: .normal)
                emoticonButton.setTitle(emoticon?.emoji, for: .normal)
                if emoticon!.isRemoved {
                    emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), for: .normal)
                }
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
    private lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: EmoticonLayout())
    private lazy var toolbar = UIToolbar()
    private class EmoticonLayout: UICollectionViewFlowLayout {
        override func prepare() {
            super.prepare()
            let col: CGFloat = 7
            let row: CGFloat = 3
            let w = collectionView!.bounds.width / col
            let margin = CGFloat(Int((collectionView!.bounds.height - row * w) * 0.5))
            itemSize = CGSize(width: w, height: w)
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
            scrollDirection = .horizontal
            collectionView?.isPagingEnabled = true
            collectionView?.bounces = false
        }
    }
}
private extension EmoticonView {
    func setupUI() {
        backgroundColor = .white
        addSubview(collectionView)
        addSubview(toolbar)
        toolbar.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(36)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(toolbar.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
        prepareToolbar()
        prepareCollectionView()
    }
    func prepareToolbar() {
        tintColor = .darkGray
        var items = [UIBarButtonItem]()
        var index = 0
        for p in packages {
            items.append(UIBarButtonItem(title: p.group_name_cn, style: .plain, target: self, action: #selector(EmoticonView.clickItem(item:))))
            items.last?.tag = index
            index += 1
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolbar.items = items
    }
    @objc func clickItem(item: UIBarButtonItem) {
        let indexPath = IndexPath(item: 0, section: item.tag)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.white
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
