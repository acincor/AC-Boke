//
//  UserCollectionCellView.swift
//  AC博客
//
//  Created by AC on 2022/9/11.
//

import UIKit
private let UserCollectionViewCellId = "UserCollectionViewCellId"
class UserCollectionCellView: UIView {
    let friendListViewModel = ElseListViewModel(clas: .friend)
    private var selectedViewModelCallBack: (_ viewModel: UserViewModel)->()
    init(selectedViewModel: @escaping(_ viewModel: UserViewModel)->()) {
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
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.register(UserCollectionCell.self, forCellWithReuseIdentifier: UserCollectionViewCellId)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}
extension UserCollectionCellView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendListViewModel.list.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return friendListViewModel.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCellId, for: indexPath) as! UserCollectionCell
        cell.viewModel = friendListViewModel.list[indexPath.row]
        cell.topView.nameLabel.text = friendListViewModel.list[indexPath.row].user.user
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = friendListViewModel.list[indexPath.row]
        selectedViewModelCallBack(user)
    }
}
