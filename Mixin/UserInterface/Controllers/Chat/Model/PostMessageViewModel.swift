import UIKit
import SwiftyMarkdown
import MixinServices

class PostMessageViewModel: TextMessageViewModel, BackgroundedTrailingInfoViewModel {
    
    override var statusNormalTintColor: UIColor {
        .white
    }
    
    override var trailingInfoColor: UIColor {
        .white
    }
    
    override var maxNumberOfLines: Int? {
        10
    }
    
    override var contentAttributedString: NSAttributedString {
        let md = SwiftyMarkdown(string: markdown)
        md.link.color = .theme
        let size = Counter(value: 15)
        for style in [md.body, md.h6, md.h5, md.h4, md.h3, md.h2, md.h1] {
            style.fontSize = CGFloat(size.advancedValue)
        }
        return md.attributedString()
    }
    
    override init(message: MessageItem) {
        super.init(message: message)
        let maxNumberOfLines = self.maxNumberOfLines ?? 10
        var lines = [String]()
        message.content.enumerateLines { (line, stop) in
            lines.append(line)
            if lines.count == maxNumberOfLines {
                stop = true
            }
        }
        self.markdown = lines.joined(separator: "\n")
    }
    
    var trailingInfoBackgroundFrame = CGRect.zero
    
    private(set) var cachedSnapshot = [UserInterfaceStyle: UIImage]()
    
    private lazy var snapshotter = PostSnapshotter(markdown: markdown)
    
    private var markdown: String!
    private var pendingSnapshots = Set<UserInterfaceStyle>()
    
    override func layout(width: CGFloat, style: MessageViewModel.Style) {
        super.layout(width: width, style: style)
        layoutTrailingInfoBackgroundFrame()
    }
    
    override func linkRanges(from string: String) -> [Link.Range] {
        []
    }
    
    func scheduleSnapshot() {
        let style = UserInterfaceStyle.current
        guard !pendingSnapshots.contains(style) else {
            return
        }
        pendingSnapshots.insert(style)
        let runLoop = CFRunLoopGetCurrent()
        let mode = CFRunLoopMode.defaultMode!
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, false, 0) { (observer, activity) in
            self.performSelector(onMainThread: #selector(self.takeSnapshot),
                                 // Swift Enum crashes for mysterious reason
                                 with: NSNumber(value: style.rawValue),
                                 waitUntilDone: false,
                                 modes: [mode.rawValue as String])
            CFRunLoopRemoveObserver(runLoop, observer, mode)
        }
        CFRunLoopAddObserver(runLoop, observer, mode)
    }
    
    @objc private func takeSnapshot(for styleRawValue: NSNumber) {
        let style = UserInterfaceStyle(rawValue: styleRawValue.intValue) ?? .light
        let image = snapshotter.make(width: contentLabelFrame.width, style: style)
        cachedSnapshot[style] = image
        pendingSnapshots.remove(style)
    }
    
}

extension PostMessageViewModel: SharedMediaItem {
    
    var messageId: String {
        message.messageId
    }
    
    var createdAt: String {
        message.createdAt
    }
    
}
