//
//  PhotoBrowserAnimator.swift
//  AC博客
//
//  Created by AC on 2022/12/1.
//

import UIKit

protocol PhotoBrowserDismissDelegate: NSObjectProtocol {
    func imageViewForDimiss() -> UIImageView
    func indexPathForDimiss() -> IndexPath
}
@objc protocol PhotoBrowserPresentDelegate: NSObjectProtocol {
    
    /// 指定 indexPath 对应的 imageView，用来做动画效果
    @objc optional func imageViewForPresent(indexPath: IndexPath) -> UIImageView
    
    /// 动画转场的起始位置
    @objc optional func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect
    
    /// 动画转场的目标位置
    @objc optional func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect
}

class PhotoBrowserAnimator: NSObject, UIViewControllerTransitioningDelegate {
    weak var presentDelegate: PhotoBrowserPresentDelegate?
    weak var dismissDelegate: PhotoBrowserDismissDelegate?
    var indexPath: IndexPath?
    private var isPresented = false
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
#endif
    func setDelegateParams(present Delegate: PhotoBrowserPresentDelegate, using indexPath: IndexPath, dimissDelegate: PhotoBrowserDismissDelegate) {
        self.presentDelegate = Delegate
        self.indexPath = indexPath
        self.dismissDelegate = dimissDelegate
    }
}
extension PhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresented ? present(transition: transitionContext) : dismiss(transition: transitionContext)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
    private func present(transition Context: UIViewControllerContextTransitioning) {
        guard let presentDelegate = presentDelegate, let indexPath = indexPath else{
            return
        }
        let toView = Context.view(forKey: .to)
        Context.containerView.addSubview(toView!)
        let iv = presentDelegate.imageViewForPresent?(indexPath: indexPath)
        iv?.frame = presentDelegate.photoBrowserPresentFromRect!(indexPath: indexPath)
        Context.containerView.addSubview(iv!)
        toView?.alpha = 0
        UIView.animate(withDuration: transitionDuration(using: Context), animations: {
            iv?.frame = (presentDelegate.photoBrowserPresentToRect?(indexPath: indexPath))!
            toView?.alpha = 1
        }) { _ in
            iv?.removeFromSuperview()
            Context.completeTransition(true)
        }
    }
    private func dismiss(transition Context: UIViewControllerContextTransitioning) {
        guard let presentDelegate = presentDelegate, let dismissDelegate = dismissDelegate else{
            return
        }
        let fromView = Context.view(forKey: .from)
        fromView?.removeFromSuperview()
        let iv = dismissDelegate.imageViewForDimiss()
        Context.containerView.addSubview(iv)
        let indexPath = dismissDelegate.indexPathForDimiss()
        UIView.animate(withDuration: transitionDuration(using: Context),animations: { [self] in
            UIView.animate(withDuration: transitionDuration(using: Context)) {
                iv.frame = (presentDelegate.photoBrowserPresentFromRect?(indexPath: indexPath))!
            }
        }) { _ in
            iv.removeFromSuperview()
            Context.completeTransition(true)
        }
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}
