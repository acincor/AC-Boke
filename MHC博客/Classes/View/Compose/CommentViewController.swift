//
//  ComposeViewController.swift
//  MHC微博
//
//  Created by mhc team on 2022/11/11.
//

import UIKit
import WebKit

class CommentViewController: UIViewController{
    override var description: String {
        return "这是一个comment类，啥也没有"
    }
    
    var toolbar: UIToolbar = UIToolbar()
    lazy var textView:UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.textColor = .label
        tv.alwaysBounceVertical = true
        tv.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag
        tv.delegate = self
        return tv
    }()
    private lazy var emoticonView: EmoticonView = EmoticonView { emoticon in
        self.textView.insertEmoticon(emoticon)
    }
    @objc func close() {
        textView.resignFirstResponder()
        dismiss(animated: true,completion: nil)
    }
    @objc private func selectEmoticon() {
        textView.resignFirstResponder()
        textView.inputView = textView.inputView == nil ? emoticonView : nil
        textView.becomeFirstResponder()
    }
    private lazy var placeHolderLabel: UILabel = UILabel(title: "善言感动人心，恶语伤人心...",fontSize: 18,color: UIColor(white: 0.6, alpha: 1.0))
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.keyboardChange(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        setupUI()
    }
    @objc private func keyboardChange(_ n: NSNotification) {
        let rect = (n.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (n.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let offset = -UIScreen.main.bounds.height + rect.origin.y
        toolbar.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(offset)
        }
        let curve = (n.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue
        //UIView.animate(withDuration: duration) {
        UIViewPropertyAnimator(duration: duration, curve: UIView.AnimationCurve(rawValue: curve)!).startAnimation()
        self.view.layoutIfNeeded()
    }
}
extension CommentViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        automaticallyAdjustsScrollViewInsets = false
        prepare()
        prepareTool()
        prepareTextView()
    }
    private func prepare() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(self.close))
        navigationItem.leftBarButtonItem?.tintColor = .red
        navigationItem.rightBarButtonItem?.tintColor = .red
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 36))
        navigationItem.titleView = titleView
        let titleLabel = UILabel(title: "发评论",fontSize: 15)
        let nameLabel = UILabel(title: UserAccountViewModel.sharedUserAccount.account?.user ?? "", fontSize: 13,color:UIColor(white: 0.6, alpha: 1.0))
        titleView.addSubview(titleLabel)
        titleView.addSubview(nameLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(titleView.snp.centerX)
            make.top.equalTo(titleView.snp.top)
        }
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(titleView.snp.centerX)
            make.bottom.equalTo(titleView.snp.bottom)
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    private func prepareTextView() {
        textView.addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.top).offset(8)
            make.left.equalTo(textView.snp.left).offset(5)
        }
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(toolbar.snp.top)
        }
    }
    private func prepareTool() {
        view.addSubview(toolbar)
        toolbar.backgroundColor = .init(white: 0.8, alpha: 1.0)
        toolbar.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(44)
        }
        let itemSettings = [["imageName": "compose_mentionbutton_background"], ["imageName":"compose_trendbutton_background"],["imageName":"compose_emoticonbutton_background","actionName":"selectEmoticon"],["imageName": "compose_pic_big_add"]]
        var items = [UIBarButtonItem]()
        for dict in itemSettings {
            items.append(UIBarButtonItem(imageName: dict["imageName"]!, target: self, actionName: dict["actionName"]))
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolbar.items = items
    }
}
extension CommentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
        placeHolderLabel.isHidden = textView.hasText
    }
}
