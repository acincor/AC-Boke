//
//  UserAgreementViewController.swift
//  AC博客
//
//  Created by AC on 2023/8/27.
//

import UIKit

class UserAgreementViewController: UIViewController {
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    override func viewDidLoad() {
        super.viewDidLoad()
        let textView = UITextView(frame: UIScreen.main.bounds)
        guard let userAgreement = Bundle.main.path(forResource: "用户协议", ofType: "txt") else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("似乎找不到目录", comment: ""))
            return
        }
        do{
            let readStr:NSString=try NSString(contentsOfFile: userAgreement, encoding: String.Encoding.utf8.rawValue)
            textView.text = readStr as String
            textView.isEditable = false
            title = NSLocalizedString("用户协议", comment: "")
            view = textView
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("关闭", comment: ""), style: .plain, target: self, action: #selector(self.closeUserAgreement))
            navigationItem.leftBarButtonItem?.tintColor = .red
        }catch _ {
        }
        // Do any additional setup after loading the view.
    }
    @objc func closeUserAgreement() {
        self.dismiss(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
