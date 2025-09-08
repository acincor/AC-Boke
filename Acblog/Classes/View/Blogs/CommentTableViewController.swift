//
//  CommentTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit

class CommentTableViewController: BlogTableViewController {
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
    //var int = 0
}
extension CommentTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = statusListViewModel.statusList[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! StatusCell
        cell.bottomView.commentButton.setTitle("\(vm.status.comment_count)", for: .normal)
        cell.bottomView.commentButton.vm = vm
        cell.bottomView.commentButton.addTarget(self, action: #selector(self.compose(_:)), for: .touchUpInside)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = statusListViewModel.statusList[indexPath.row]
        let vc = QuoteTableViewController(vm)
        let nav = UINavigationController(rootViewController:vc)
        nav.modalPresentationStyle = .custom
        present(nav, animated: true)
    }
    @objc func compose(_ sender: UIButton) {
        let nav = ComposeViewController(sender.vm!.status.comment_id, sender.vm!.status.id)
        self.present(UINavigationController(rootViewController: nav), animated: true)
    }
}
