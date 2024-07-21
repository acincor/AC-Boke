//
//  NewFeatureViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit


/// 可重用 CellId
private let WBNewFeatureViewCellId = "WBNewFeatureViewCellId"
/// 新特性图像的数量
private let WBNewFeatureImageCount = 4

class NewFeatureViewController: UICollectionViewController {
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    // MARK: - 构造函数
    init() {
        // super.指定的构造函数
        let layout = UICollectionViewFlowLayout()
        
        //设置每个单元格的尺寸
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumInteritemSpacing = 0     //设置单元格的间距为0
        layout.minimumLineSpacing = 0           //设置行间距为0
        layout.scrollDirection = .horizontal   //设置滚动方向是横向
        
        // 构造函数，完成之后内部属性才会被创建
        super.init(collectionViewLayout: layout)
        collectionView?.isPagingEnabled = true   //开启分页
        collectionView?.bounces = false         //去掉弹簧效果
        
        //去掉水平方向上的滚动条
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // iOS 7.0 开始，就推荐要隐藏状态栏，可以每个控制器分别设置，默认是 NO
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册可重用Cell
        self.collectionView!.register(NewFeatureCell.self, forCellWithReuseIdentifier: WBNewFeatureViewCellId)
    }
    
    // MARK: UICollectionViewDataSource
    // 返回每个分组中，单元格的数量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WBNewFeatureImageCount
    }
    
    // 返回每个单元格
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WBNewFeatureViewCellId, for: indexPath) as! NewFeatureCell
        cell.imageIndex = indexPath.item
        
        return cell
    }
    
    // ScrollView 停止滚动方法
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 在最后一页才调用动画方法
        // 根据 contentOffset 计算页数
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        // 判断是否是最后一页
        if page != WBNewFeatureImageCount - 1 {
            return
        }
        
        // Cell 播放动画
        let cell = collectionView?.cellForItem(
            at: NSIndexPath(item: page, section: 0) as IndexPath) as! NewFeatureCell
        
        // 显示动画
        cell.showButtonAnim()
    }
    
}

// 新特性 Cell
private class NewFeatureCell: UICollectionViewCell {
    
    /// 图像属性
    var imageIndex: Int = 0 {
        didSet {
            iconView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            startButton.isHidden = true
        }
    }
    
    /// 点击开始体验按钮
    @objc private func clickStartButton() {
        NotificationCenter.default.post(name: .init(rawValue: WBSwitchRootViewControllerNotification), object: nil)
    }
    
    /// 显示按钮动画
    func showButtonAnim() {
        startButton.isHidden = false
        startButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        startButton.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 1.6,     // 动画时长
            delay: 0,                           // 延时时间
            usingSpringWithDamping: 0.6,    // 弹力系数，0~1，越小越弹
            initialSpringVelocity: 10,      // 初始速度，模拟重力加速度
            options: [],                       // 动画选项
            animations: { () -> Void in
            self.startButton.transform = CGAffineTransform.identity
        }) { (_) -> Void in
            self.startButton.isUserInteractionEnabled = true
        }
    }
    
    // frame 的大小是由 layout.itemSize 指定的
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 1. 添加控件
        addSubview(iconView)
        addSubview(startButton)
        
        // 2. 指定位置
        iconView.frame = bounds
        
        startButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).multipliedBy(0.7)
        }
        
        // 监听方法
        startButton.addTarget(self, action:#selector(NewFeatureCell.clickStartButton), for: .touchUpInside)
        
        startButton.isHidden = true

    }
    
    // MARK: - 懒加载控件
    /// 图像
    private lazy var iconView: UIImageView = UIImageView()

    /// 开始体验按钮
    private lazy var startButton: UIButton = UIButton(title: NSLocalizedString("开始体验", comment: ""), color:.white, backImageName: "new_feature_finish_button")
}

