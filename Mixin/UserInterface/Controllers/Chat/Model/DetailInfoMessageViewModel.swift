import UIKit
import MixinServices

class DetailInfoMessageViewModel: MessageViewModel {
    
    static let bubbleMargin = Margin(leading: 8, trailing: 66, top: 0, bottom: 0)
    static let statusLeftMargin: CGFloat = 4
    static let identityIconLeftMargin: CGFloat = 4
    static let identityIconSize = R.image.ic_user_bot()!.size
    static let encryptedIconRightMargin: CGFloat = 4
    
    class var bubbleImageSet: BubbleImageSet.Type {
        return GeneralBubbleImageSet.self
    }
    
    var timeMargin: Margin {
        Margin(leading: 16, trailing: 10, top: 0, bottom: 8)
    }
    
    var statusImage: UIImage?
    var statusTintColor: UIColor = .accessoryText
    var fullnameFrame = CGRect(x: 24, y: 1, width: 24, height: 23)
    var fullnameColor = UIColor.text
    var encryptedIconFrame = CGRect(origin: .zero, size: R.image.ic_message_encrypted()!.size)
    var timeFrame = CGRect(x: 0, y: 0, width: 0, height: 12)
    var statusFrame = CGRect.zero
    var identityIconFrame = CGRect(origin: .zero, size: DetailInfoMessageViewModel.identityIconSize)
    
    var statusNormalTintColor: UIColor {
        return .accessoryText
    }
    
    var maxContentWidth: CGFloat {
        return layoutWidth
            - DetailInfoMessageViewModel.bubbleMargin.horizontal
            - contentMargin.horizontal
    }
    
    var showStatusImage: Bool {
        return !style.contains(.received) || message.status == MessageStatus.FAILED.rawValue
    }
    
    var status: String {
        get {
            return message.status
        }
        set {
            message.status = newValue
            updateStatusImageAndTintColor()
        }
    }
    
    private let fullnameVerticalInset: CGFloat = 6
    private let minFullnameWidth: CGFloat = 16
    private let minEncryptedIconLeftMargin: CGFloat = 8
    private let statusHighlightTintColor = UIColor.theme
    
    override func layout(width: CGFloat, style: MessageViewModel.Style) {
        super.layout(width: width, style: style)
        let fullnameSize = (message.userFullName as NSString)
            .boundingRect(with: UIView.layoutFittingExpandedSize,
                          options: [],
                          attributes: [.font: MessageFontSet.fullname.scaled],
                          context: nil)
            .size
        fullnameFrame.size = CGSize(width: ceil(fullnameSize.width),
                                    height: ceil(fullnameSize.height) + fullnameVerticalInset)
        updateStatusImageAndTintColor()
        backgroundImage = type(of: self).bubbleImageSet.image(forStyle: style, highlight: false)
        timeFrame.size = ceil((time as NSString).size(withAttributes: [.font: MessageFontSet.time.scaled]))
    }
    
    func layoutDetailInfo(insideBackgroundImage: Bool = true, backgroundImageFrame: CGRect) {
        if insideBackgroundImage {
            timeFrame.origin = CGPoint(x: backgroundImageFrame.maxX - timeFrame.width,
                                       y: backgroundImageFrame.maxY - timeMargin.bottom - timeFrame.height)
        } else {
            timeFrame.origin = CGPoint(x: backgroundImageFrame.maxX - timeFrame.width,
                                       y: backgroundImageFrame.maxY)
        }
        if showStatusImage {
            statusFrame.size = ImageSet.MessageStatus.size
        } else {
            statusFrame.size = .zero
        }
        if style.contains(.received) {
            var offset = timeMargin.trailing
            if message.status == MessageStatus.FAILED.rawValue {
                offset += DetailInfoMessageViewModel.statusLeftMargin + statusFrame.width
            }
            timeFrame.origin.x -= offset
        } else {
            let offset = timeMargin.leading
                + DetailInfoMessageViewModel.statusLeftMargin
                + statusFrame.width
            timeFrame.origin.x -= offset
        }
        if style.contains(.fullname) {
            let index = message.userId.positiveHashCode() % UIColor.usernameColors.count
            fullnameColor = UIColor.usernameColors[index]
        }
        layoutEncryptedIconFrame()
        statusFrame.origin = CGPoint(x: timeFrame.maxX + DetailInfoMessageViewModel.statusLeftMargin,
                                     y: timeFrame.origin.y + (timeFrame.height - statusFrame.height) / 2)
        fullnameFrame.size.width = max(minFullnameWidth, min(fullnameFrame.size.width, maxContentWidth))
        identityIconFrame.origin = CGPoint(x: fullnameFrame.maxX + DetailInfoMessageViewModel.identityIconLeftMargin,
                                           y: fullnameFrame.origin.y + (fullnameFrame.height - identityIconFrame.height) / 2)
    }
    
    func layoutEncryptedIconFrame() {
        var x = timeFrame.origin.x - Self.encryptedIconRightMargin - encryptedIconFrame.size.width
        let diff = x - minEncryptedIconLeftMargin
        if style.contains(.received) && isEncrypted && diff < 0 {
            x -= diff
            timeFrame.origin.x -= diff
        }
        encryptedIconFrame.origin = CGPoint(x: x, y: timeFrame.origin.y + (timeFrame.height - encryptedIconFrame.height) / 2)
    }
    
    private func updateStatusImageAndTintColor() {
        guard let status = MessageStatus(rawValue: message.status) else {
            statusImage = nil
            return
        }
        if showStatusImage {
            switch status {
            case .SENDING, .FAILED, .UNKNOWN:
                statusImage = ImageSet.MessageStatus.pending
                statusTintColor = statusNormalTintColor
            case .SENT:
                statusImage = ImageSet.MessageStatus.checkmark
                statusTintColor = statusNormalTintColor
            case .DELIVERED:
                statusImage = ImageSet.MessageStatus.doubleCheckmark
                statusTintColor = statusNormalTintColor
            case .READ:
                statusImage = ImageSet.MessageStatus.doubleCheckmark
                statusTintColor = statusHighlightTintColor
            }
        } else {
            if status == .FAILED {
                statusImage = ImageSet.MessageStatus.pending
                statusTintColor = statusNormalTintColor
            } else {
                statusImage = nil
            }
        }
    }
    
}
