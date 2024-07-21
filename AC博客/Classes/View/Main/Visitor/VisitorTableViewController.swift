//
//  VisitorTableViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/7.
//

import UIKit

class VisitorTableViewController: UITableViewController {
    var userLogon = UserAccountViewModel.sharedUserAccount.userLogon
    var visitorView: VisitorView?
    override func loadView() {
        userLogon ? super.loadView() : setupVisitorView()
    }
    private func setupVisitorView() {
        visitorView = VisitorView()
        view = visitorView
        visitorView?.registerButton.addTarget(self, action: #selector(VisitorTableViewController.visitorViewDidRegister), for: .touchUpInside)
        //view.backgroundColor = UIColor.red
        visitorView?.loginButton.addTarget(self, action: #selector(VisitorTableViewController.visitorViewDidLogin), for: .touchUpInside)
    }
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension VisitorTableViewController {
    @objc func visitorViewDidRegister() {
        let vc = OAuthViewController(.注册)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    @objc func visitorViewDidLogin() {
        let vc = OAuthViewController(.登录)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}
