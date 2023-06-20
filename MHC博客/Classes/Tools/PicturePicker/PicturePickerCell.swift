//
//  PicturePickerCell.swift
//  SelectPhotos
//
//  Created by mhc team on 2022/11/26.
//

import Foundation
import UIKit
import SwiftUI
@objc protocol PicturePickerCellDelegate: NSObjectProtocol {
    @objc optional func picturePickerDidAdd(cell: PicturePickerCell)
    @objc optional func picturePickerDidRemove(cell: PicturePickerCell)
}
class PicturePickerCell: UICollectionViewCell {
    var image: UIImage? {
        didSet {
            addButton.setImage(image ?? UIImage(named: "compose_pic_add"), for: .normal)
        }
    }
    weak var pictureDelegate: PicturePickerCellDelegate?
    @objc func add() {
        pictureDelegate?.picturePickerDidAdd?(cell: self)
    }
    @objc func remove() {
        pictureDelegate?.picturePickerDidRemove?(cell: self)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        addButton.frame = bounds
        addButton.imageView?.contentMode = .scaleAspectFill
        removeButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.right.equalTo(contentView.snp.right)
        }
        addButton.addTarget(self, action: #selector(PicturePickerCell.add), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(PicturePickerCell.remove), for: .touchUpInside)
    }
    private lazy var addButton: UIButton = UIButton(imageName: "compose_pic_add", backImageName: nil)
    private lazy var removeButton: UIButton = UIButton(imageName: "compose_photo_close", backImageName: nil)
}
