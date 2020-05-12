import UIKit

class PostMessageCell: TextMessageCell {
    
    let postImageView = UIImageView()
    let expandImageView = UIImageView(image: R.image.conversation.ic_message_expand())
    let trailingInfoBackgroundView = TrailingInfoBackgroundView()
    
    override func prepare() {
        messageContentView.addSubview(trailingInfoBackgroundView)
        super.prepare()
        messageContentView.addSubview(expandImageView)
        encryptedImageView.alpha = 0.9
        statusImageView.alpha = 0.9
        postImageView.clipsToBounds = true
        postImageView.contentMode = .topLeft
        messageContentView.addSubview(postImageView)
    }
    
    override func render(viewModel: MessageViewModel) {
        super.render(viewModel: viewModel)
        let expandImageMargin: CGFloat
        if viewModel.style.contains(.received) {
            expandImageMargin = 9
        } else {
            expandImageMargin = 16
        }
        let origin = CGPoint(x: viewModel.backgroundImageFrame.maxX - expandImageView.frame.width - expandImageMargin,
                             y: viewModel.backgroundImageFrame.origin.y + 8)
        expandImageView.frame.origin = origin
        if let viewModel = viewModel as? PostMessageViewModel {
            postImageView.frame = viewModel.contentLabelFrame
            trailingInfoBackgroundView.frame = viewModel.trailingInfoBackgroundFrame
        }
        reloadPostImage()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadPostImage()
    }
    
    private func reloadPostImage() {
        guard let viewModel = viewModel as? PostMessageViewModel else {
            return
        }
        if let snapshot = viewModel.cachedSnapshot[.current] {
            postImageView.image = snapshot
            postImageView.isHidden = false
            contentLabel.isHidden = true
        } else {
            viewModel.scheduleSnapshot()
            postImageView.isHidden = true
            contentLabel.isHidden = false
        }
    }
    
}
