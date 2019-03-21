import UIKit

class PinValidationPresentationController: UIPresentationController {
    
    lazy var blurEffect = UIBlurEffect(style: .dark)
    lazy var backgroundView = UIVisualEffectView(effect: nil)
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            backgroundView.frame = containerView.bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.insertSubview(backgroundView, at: 0)
        }
        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.effect = blurEffect
            return
        }
        coordinator.animate(alongsideTransition: { (_) in
            self.backgroundView.effect = self.blurEffect
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.effect = nil
            return
        }
        coordinator.animate(alongsideTransition: { (_) in
            self.backgroundView.effect = nil
        })
    }
    
}
