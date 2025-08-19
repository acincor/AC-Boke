//
//  StatusCellTopView.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit

class StatusCellTopView: UIView {
    // MARK: - 懒加载控件
    /// 头像
    lazy var iconView: UIImageView = UIImageView(image: .avatarDefaultBig)
    
    /// 姓名
    lazy var nameLabel: UILabel = UILabel(title: "王老五", fontSize: 14)
    
    /// 时间标签
    private lazy var timeLabel: UILabel = UILabel(title: "现在", fontSize: 11, color: UIColor.red)
    
    /// 来源标签
    private lazy var sourceLabel: UILabel = UILabel(title: "来源", fontSize: 11)
    var viewModel: StatusViewModel? {
        didSet {
            // 姓名
            timeLabel.text = viewModel?.createAt
            self.nameLabel.text = viewModel?.status.user
            nameLabel.textColor = .red
            if viewModel?.status.source != nil ? viewModel?.status.source != "unknown": false{
                sourceLabel.text = viewModel?.status.source
            }else {
                sourceLabel.text = "未知"
            }
            // 头像
            iconView.kf.setImage(with: viewModel?.userProfileUrl, placeholder: viewModel?.userDefaultIconView, options: [.forceRefresh])
            iconView.layer.cornerRadius = 5
            iconView.clipsToBounds = true
            iconView.isUserInteractionEnabled = true
            
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension StatusCellTopView {
    private func setupUI() {
        let sepView = UIView()
        sepView.backgroundColor = .systemBackground
        addSubview(sepView)
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        iconView.snp.makeConstraints { make in
            make.top.equalTo(sepView.snp.bottom).offset(StatusCellMargin)
            make.left.equalTo(self.snp.left).offset(StatusCellMargin)
            make.width.equalTo(StatusCellIconWidth)
            make.height.equalTo(StatusCellIconWidth)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.top)
            make.left.equalTo(iconView.snp.right).offset(StatusCellMargin)
        }
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconView.snp.bottom)
            make.left.equalTo(iconView.snp.right).offset(StatusCellMargin)
        }
        sourceLabel.snp.makeConstraints { make in
            make.bottom.equalTo(timeLabel.snp.bottom)
            make.left.equalTo(timeLabel.snp.right).offset(StatusCellMargin)
        }
        sepView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(StatusCellMargin)
        }
    }
}
extension UITapGestureRecognizer {
    private struct AssociatedKey {
        @MainActor static var sender: String?
        @MainActor static var sender2: String?
        @MainActor static var sender3: String?
        @MainActor static var sender4: URL?
    }
    func setAssociated<T>(value: T, associatedKey: UnsafeRawPointer, policy: objc_AssociationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> Void {
        objc_setAssociatedObject(self, associatedKey, value, policy)
    }
    
    func getAssociated<T>(associatedKey: UnsafeRawPointer) -> T? {
        let value = objc_getAssociatedObject(self, associatedKey) as? T
        return value;
    }
    public var sender4: URL? {
        get {
            withUnsafePointer(to: &AssociatedKey.sender4) { pointer in
                getAssociated(associatedKey: pointer)
            }
        }
        
        set {
            withUnsafePointer(to: &AssociatedKey.sender4) { pointer in
                setAssociated(value: newValue,associatedKey: pointer)
            }
        }
    }
    public var sender: String? {
        get {
            withUnsafePointer(to: &AssociatedKey.sender) { pointer in
                getAssociated(associatedKey: pointer)
            }
        }
        
        set {
            withUnsafePointer(to: &AssociatedKey.sender) { pointer in
                setAssociated(value: newValue,associatedKey: pointer)
            }
        }
    }
    public var sender3: String? {
        get {
            withUnsafePointer(to: &AssociatedKey.sender3) { pointer in
                getAssociated(associatedKey: pointer)
            }
        }
        
        set {
            withUnsafePointer(to: &AssociatedKey.sender3) { pointer in
                setAssociated(value: newValue,associatedKey: pointer)
            }
        }
    }
    
    public var sender2: String? {
        get {
            withUnsafePointer(to: &AssociatedKey.sender2) { pointer in
                getAssociated(associatedKey: pointer)
            }
        }
        
        set {
            withUnsafePointer(to: &AssociatedKey.sender2) { pointer in
                setAssociated(value: newValue,associatedKey: pointer)
            }
        }
    }
}
