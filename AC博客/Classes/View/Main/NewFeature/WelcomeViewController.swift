//
//  WelcomeViewController.swift
//  AC博客
//
//  Created by AC on 2022/9/10.
//

import UIKit

class WelcomeViewController: UIViewController {
#if os(visionOS)
override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    return .glass
}
#endif
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        iconView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-view.bounds.height + 200)
        }
        welcomeLabel.alpha = 0
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.8, animations: {
                self.welcomeLabel.alpha = 1
            }, completion: { (_) in
                NotificationCenter.default.post(name: .init(rawValue: WBSwitchRootViewControllerNotification), object: nil)
            })
        }
    }
    override func loadView() {
        backImageView.contentMode = .scaleAspectFit
        backImageView.backgroundColor = UIColor(named: "ad_backColor")
        view = backImageView
        setupUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        iconView.sd_setImage(with: UserAccountViewModel.sharedUserAccount.portraitUrl, placeholderImage: UIImage(named: "avatar_default_big"), completed: nil)
        // Do any additional setup after loading the view.
    }
    private lazy var backImageView: UIImageView = UIImageView(imageName:"ad_background")
    private lazy var iconView: UIImageView = {
        let iv = UIImageView(imageName: "avatar_default_big")
        iv.layer.cornerRadius = 45
        iv.layer.masksToBounds = true
        return iv
    }()
    private lazy var welcomeLabel: UILabel = UILabel(title:String.localizedStringWithFormat(NSLocalizedString("欢迎%@归来", comment: ""), UserAccountViewModel.sharedUserAccount.account!.user!),fontSize: 18)
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension WelcomeViewController {
    private func setupUI() {
        view.addSubview(iconView)
        view.addSubview(welcomeLabel)
        iconView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom).offset(-200)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(iconView.snp.centerX)
            make.top.equalTo(iconView.snp.bottom).offset(16)
        }
    }
}
