//
//  LiveCell.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit
private let TrendViewCellId = "TrendViewCellId"
class TrendCellView: UIView {
    var trendList = [String]()
    private var selectedViewModelCallBack: (_ viewModel: String)->()
    init(selectedViewModel: @escaping(_ viewModel: String)->()) {
        selectedViewModelCallBack = selectedViewModel
        var rect = UIScreen.main.bounds
        rect.size.height = 226
        super.init(frame: rect)
        backgroundColor = .systemBackground
        setupUI()
    }
    lazy var collectionView = UICollectionView(frame: CGRectZero,collectionViewLayout: UICollectionViewFlowLayout())
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TrendCellView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
        prepareCollectionView()
    }
    func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.register(TrendCell.self, forCellWithReuseIdentifier: TrendViewCellId)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}
extension TrendCellView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trendList.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendViewCellId, for: indexPath) as! TrendCell
        cell.model = trendList[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = trendList[indexPath.row]
        selectedViewModelCallBack(user)
    }
}
