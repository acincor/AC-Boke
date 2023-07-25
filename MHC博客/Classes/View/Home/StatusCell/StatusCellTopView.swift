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
    private lazy var iconView: UIImageView = UIImageView(imageName: "avatar_default_big")
    
    /// 姓名
    private lazy var nameLabel: UILabel = UILabel(title: "王老五", fontSize: 14)
    
    /// 时间标签
    private lazy var timeLabel: UILabel = UILabel(title: "现在", fontSize: 11, color: UIColor.red)
    
    /// 来源标签
    private lazy var sourceLabel: UILabel = UILabel(title: "来源", fontSize: 11)
    var viewModel: StatusViewModel? {
        didSet {
            // 姓名
            timeLabel.text = viewModel?.createAt
            self.nameLabel.text = viewModel?.status.user as? String
            nameLabel.textColor = .red
            if viewModel?.status.source != nil ? viewModel?.status.source != "unknown": false{
                sourceLabel.text = viewModel?.status.source
            }else {
                sourceLabel.text = "未知"
            }
            // 头像
            iconView.sd_setImage(with: viewModel?.userProfileUrl, placeholderImage: viewModel?.userDefaultIconView)
            iconView.layer.cornerRadius = 15
            iconView.layer.masksToBounds = true
            iconView.isUserInteractionEnabled = true
            let g = UITapGestureRecognizer(target: self, action: #selector(self.action(sender:)))
            g.sender = "\(viewModel?.status.uid ?? 0)"
            iconView.addGestureRecognizer(g)
        }
    }
    @objc func action(sender: UITapGestureRecognizer) {
        print("\(viewModel?.status.uid ?? 0)")
        NetworkTools.shared.addFriend(sender.sender) { Result, Error in
            if Error != nil {
                SVProgressHUD.showInfo(withStatus: "出错了")
                //print("Result出现错误")
                print(Error)
                return
            }
            guard let result = Result as? [String:Any] else {
                SVProgressHUD.showInfo(withStatus: "出错了")
                print("result出现转换错误")
                return
            }
            if (result["error"] != nil) {
                SVProgressHUD.showInfo(withStatus: result["error"] as? String)
                print("result出现error")
                return
            }
            guard let code = result["code"] as? String else {
                SVProgressHUD.showInfo(withStatus: "出错了")
                print("result出现转换错误")
                return
            }
            if (code != "delete") {
                SVProgressHUD.showInfo(withStatus: "成功添加好友")
                //print("result出现error")
                ////print(result)
                return
            }
            SVProgressHUD.showInfo(withStatus: "成功删除/拉黑好友")
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
        sepView.backgroundColor = .white
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
        }
        
        public var sender: String {
            get {
                return objc_getAssociatedObject(self, &AssociatedKey.sender) as? String ?? ""
            }
            
            set {
                objc_setAssociatedObject(self, &AssociatedKey.sender, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
}
