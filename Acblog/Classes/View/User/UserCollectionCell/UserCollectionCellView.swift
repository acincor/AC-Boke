//
//  UserCollectionCellView.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit
let UserCollectionCellNormalId = "UserCollectionCellNormalId"
class UserCollectionView: UICollectionView {
    init() {
        let flt = UICollectionViewFlowLayout()
        flt.minimumLineSpacing = 0
        flt.minimumInteritemSpacing = 0
        flt.scrollDirection = .horizontal
        super.init(frame: CGRectZero, collectionViewLayout: flt)
        bounces = false
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        register(UserCollectionCell.self, forCellWithReuseIdentifier: LiveCellNormalId)
        backgroundColor = UIColor.systemBackground
        register(UserCollectionCell.self, forCellWithReuseIdentifier: UserCollectionCellNormalId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class UserCollectionCellView: UIView {
    let userListViewModel = UserListViewModel()
    private var selectedViewModelCallBack: (_ viewModel: UserViewModel)->()
    init(selectedViewModel: @escaping(_ viewModel: UserViewModel)->()) {
        selectedViewModelCallBack = selectedViewModel
        var rect = UIScreen.main.bounds
        rect.size.height = 226
        super.init(frame: rect)
        backgroundColor = .systemBackground
        setupUI()
    }
    lazy var collectionView = UserCollectionView()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UserCollectionCellView {
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
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}
extension UserCollectionCellView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userListViewModel.list.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionCellNormalId, for: indexPath) as! UserCollectionCell
        cell.uvm = userListViewModel.list[indexPath.row]
        //cell.frame = cell.topView.frame
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = userListViewModel.list[indexPath.row]
        selectedViewModelCallBack(user)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 125, height: userListViewModel.list[indexPath.row].rowHeight+StatusCellMargin)
    }
}
