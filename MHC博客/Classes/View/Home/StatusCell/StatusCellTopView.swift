//
//  StatusCellTopView.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

class StatusCellTopView: UIView {
    // MARK: - 懒加载控件
    /// 头像
    lazy var iconView: UIImageView = UIImageView(imageName: "avatar_default_big")
    
    /// 姓名
    lazy var nameLabel: UILabel = UILabel(title: "王老五", fontSize: 14)
    
    /// 时间标签
    private lazy var timeLabel: UILabel = UILabel(title: "现在", fontSize: 11, color: UIColor.red)
    
    /// 来源标签
    private lazy var sourceLabel: UILabel = UILabel(title: "来源", fontSize: 11)
    var viewModel: CustomStringConvertible? {
        didSet {
            // 姓名
            guard let viewModel = viewModel as? StatusViewModel else {
                return
            }
            timeLabel.text = viewModel.createAt
            self.nameLabel.text = viewModel.status.user
            nameLabel.textColor = .red
            if viewModel.status.source != nil ? viewModel.status.source != "unknown": false{
                sourceLabel.text = viewModel.status.source
            }else {
                sourceLabel.text = "未知"
            }
            // 头像
            iconView.sd_setImage(with: viewModel.userProfileUrl, placeholderImage: viewModel.userDefaultIconView)
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
            static var sender: String = "sender"
        static var sender2: String = "sender2"
        static var sender3: String = "sender3"
        static var sender4: URL = URL(string: rootHost+"/api/MHC.png")!
        }
    public var sender4: URL {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.sender4) as? URL ?? URL(string: rootHost+"/api/MHC.png")!
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.sender4, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    public var sender: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.sender) as? String ?? ""
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.sender, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    public var sender3: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.sender3) as? String ?? ""
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.sender3, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
        
        public var sender2: String {
            get {
                return objc_getAssociatedObject(self, &AssociatedKey.sender2) as? String ?? ""
            }
            
            set {
                objc_setAssociatedObject(self, &AssociatedKey.sender2, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
}
