//
//  QuoteTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit

class QuoteTableViewController: BlogTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let cell = StatusNormalCell(style: .default, reuseIdentifier: StatusCellNormalId)
        cell.viewModel = vm
        cell.bottomView.removeFromSuperview()
        tableView.tableHeaderView = cell
        guard let vm = vm else {
            return
        }
        tableView.tableHeaderView?.frame = CGRectMake(cell.frame.maxX, cell.frame.maxY, cell.frame.width, vm.rowHeight-40)
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! StatusCell
        cell.bottomView.likeButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(cell.bottomView.deleteButton.snp.right)
            make.width.equalTo(cell.bottomView.deleteButton.snp.width)
            make.right.equalTo(cell.bottomView.snp.right)
            make.height.equalTo(cell.bottomView.deleteButton.snp.height)
        }
        cell.bottomView.commentButton.removeFromSuperview()
        return cell
    }
}
