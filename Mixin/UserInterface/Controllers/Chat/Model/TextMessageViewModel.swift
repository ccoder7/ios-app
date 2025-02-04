import UIKit
import MixinServices

class TextMessageViewModel: DetailInfoMessageViewModel {
    
    override class var supportsQuoting: Bool {
        true
    }
    
    class var font: UIFont {
        UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16))
    }
    
    class var textColor: UIColor {
        return .chatText
    }
    
    var content: CoreTextLabel.Content?
    var contentLabelFrame = CGRect.zero
    var highlightPaths = [UIBezierPath]()
    
    // When layout within message bubble, set this variable to false and use the maxContentWidth
    // Set this variable to true will layout with raw width which passed to layout func
    // e.g. when performing layout in SharedMediaPostTableViewController
    var layoutWithRawWidth = false
    
    private let trailingInfoLeftMargin: CGFloat = 20
    private let minimumTextSize = CGSize(width: 5, height: 17)
    private let linkColor = UIColor.systemTint
    private let hightlightPathCornerRadius: CGFloat = 4
    
    private var contentSize = CGSize.zero // contentSize is textSize concatenated with additionalTrailingSize and fullname width
    private var linkRanges = [Link.Range]()
    
    // The content presented may differs from message.content,
    // e.g. when contentAttributedString is overrided
    // highlight(keyword:) will be using this var for keyword range enumeration
    private var presentedContent: String
    
    override var debugDescription: String {
        return super.debugDescription + ", contentSize: \(contentSize), contentLength: \(message.content.count)"
    }
    
    var fullnameHeight: CGFloat {
        return style.contains(.fullname) ? fullnameFrame.height : 0
    }
    
    var backgroundWidth: CGFloat {
        let width = contentAdditionalLeadingMargin
            + contentSize.width
            + contentMargin.horizontal
        if let viewModel = quotedMessageViewModel {
            let quotedMessageWidth = viewModel.contentSize.width + Self.quotedMessageMargin.horizontal
            return max(width, quotedMessageWidth)
        } else {
            return width
        }
    }
    
    var contentLabelTopMargin: CGFloat {
        if let viewModel = quotedMessageViewModel {
            return fullnameHeight + viewModel.contentSize.height + Self.quotedMessageMargin.vertical
        } else {
            if style.contains(.fullname) {
                return fullnameFrame.height
            } else {
                return contentMargin.top
            }
        }
    }
    
    var contentAdditionalLeadingMargin: CGFloat {
        return 0
    }
    
    var maxNumberOfLines: Int? {
        nil
    }
    
    var rawContent: String {
        message.mentionedFullnameReplacedContent
    }
    
    var contentAttributedString: NSAttributedString {
        let str = NSMutableAttributedString(string: rawContent)
        str.setAttributes([.font: Self.font, .foregroundColor: Self.textColor],
                          range: NSRange(location: 0, length: str.length))
        for linkRange in linkRanges {
            str.addAttribute(.foregroundColor, value: linkColor, range: linkRange.range)
        }
        return str.copy() as! NSAttributedString
    }
    
    override init(message: MessageItem) {
        presentedContent = message.content
        super.init(message: message)
        linkRanges = self.linkRanges(from: rawContent)
    }
    
    override func quoteViewLayoutWidth(from width: CGFloat) -> CGFloat {
        width
            - Self.bubbleMargin.horizontal
            - Self.quotedMessageMargin.horizontal
            - contentMargin.horizontal
    }
    
    override func layout(width: CGFloat, style: MessageViewModel.Style) {
        super.layout(width: width, style: style)
        let attributedString = self.contentAttributedString
        presentedContent = attributedString.string
        // Make CTLine and Origins
        var (lines, lineOrigins, lineRanges, textSize, lastLineWidth) = { () -> ([CTLine], [CGPoint], [CFRange], CGSize, CGFloat) in
            let cfStr = attributedString as CFAttributedString
            let typesetter = CTTypesetterCreateWithAttributedString(cfStr)
            let typesetWidth = layoutWithRawWidth ? Double(width) : Double(maxContentWidth)
            
            var lines = [CTLine]()
            var lineOrigins = [CGPoint]()
            var lineRanges = [CFRange]()
            var characterIndex: CFIndex = 0
            var y: CGFloat?
            var lastLineWidth: CGFloat = 0
            var size = CGSize.zero
            var lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, characterIndex, typesetWidth)
            
            var didReachLineCountLimit: Bool {
                if let maxNumberOfLines = maxNumberOfLines {
                    return lines.count == maxNumberOfLines
                } else {
                    return false
                }
            }
            
            while lineCharacterCount > 0 && !didReachLineCountLimit {
                let lineRange = CFRange(location: characterIndex, length: lineCharacterCount)
                lineRanges.append(lineRange)
                
                let line = CTTypesetterCreateLine(typesetter, lineRange)
                lines.append(line)
                
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                var leading: CGFloat = 0
                let lineWidth = ceil(CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading) - CTLineGetTrailingWhitespaceWidth(line)))
                let lineHeight = max(Self.font.lineHeight, ascent + descent + leading)
                
                size.height += lineHeight
                size.width = max(size.width, lineWidth)
                
                if y == nil {
                    y = max(4, descent)
                }
                y! -= lineHeight
                let lineOrigin = CGPoint(x: 0, y: y!)
                lineOrigins.append(lineOrigin)
                
                lastLineWidth = lineWidth
                characterIndex += lineCharacterCount
                lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, characterIndex, typesetWidth)
            }
            
            size = CGSize(width: ceil(size.width), height: ceil(size.height) + 1)
            lineOrigins = lineOrigins.map {
                CGPoint(x: $0.x, y: $0.y + size.height)
            }
            
            return (lines, lineOrigins, lineRanges, size, lastLineWidth)
        }()
        
        textSize.width = max(textSize.width, minimumTextSize.width)
        textSize.height = max(textSize.height, minimumTextSize.height)
        
        // Make Links
        var links = [Link]()
        for linkRange in linkRanges {
            let linkRects: [CGRect] = lines.enumerated().compactMap({ (index, line) -> CGRect? in
                let lineOrigin = lineOrigins[index]
                let lineRange = NSRange(cfRange: lineRanges[index])
                if let intersection = lineRange.intersection(linkRange.range) {
                    return line.frame(forRange: intersection, lineOrigin: lineOrigin)
                } else {
                    return nil
                }
            })
            var path: UIBezierPath?
            for linkRect in linkRects {
                let newPath = UIBezierPath(roundedRect: linkRect, cornerRadius: hightlightPathCornerRadius)
                if path != nil {
                    path!.append(newPath)
                } else {
                    path = newPath
                }
            }
            if let path = path {
                links += linkRects.map{ Link(hitFrame: $0, backgroundPath: path, url: linkRange.url) }
            }
        }
        // Make content
        self.content = CoreTextLabel.Content(lines: lines, lineOrigins: lineOrigins, links: links)
        // Calculate content size
        let additionalTrailingSize: CGSize = {
            let statusImageWidth = showStatusImage
                ? ImageSet.MessageStatus.size.width
                : 0
            let encryptedIconWidth = isEncrypted
                ? Self.encryptedIconRightMargin + encryptedIconFrame.width
                : 0
            let width = trailingInfoLeftMargin
                + encryptedIconWidth
                + timeFrame.width
                + statusImageWidth
                + DetailInfoMessageViewModel.statusLeftMargin
            return CGSize(width: width, height: 16)
        }()
        
        var contentSize = textSize
        let lastLineWithTrailingWidth = lastLineWidth + additionalTrailingSize.width
        if lastLineWithTrailingWidth > maxContentWidth {
            contentSize.height += additionalTrailingSize.height
        } else if lines.count == 1 {
            contentSize.width = lastLineWithTrailingWidth
        } else {
            contentSize.width = max(contentSize.width, lastLineWithTrailingWidth)
        }
        if style.contains(.fullname) {
            if message.userIsBot {
                let identityIconWidth = DetailInfoMessageViewModel.identityIconLeftMargin
                    + DetailInfoMessageViewModel.identityIconSize.width
                contentSize.width = min(maxContentWidth, max(contentSize.width, fullnameFrame.size.width + identityIconWidth))
            } else {
                contentSize.width = min(maxContentWidth, max(contentSize.width, fullnameFrame.size.width))
            }
        }
        self.contentSize = contentSize
        let bubbleMargin = DetailInfoMessageViewModel.bubbleMargin
        if style.contains(.received) {
            backgroundImageFrame = CGRect(x: bubbleMargin.leading,
                                          y: 0,
                                          width: backgroundWidth,
                                          height: contentSize.height + contentLabelTopMargin + contentMargin.bottom)
            contentLabelFrame = CGRect(x: ceil(backgroundImageFrame.origin.x + contentMargin.leading),
                                       y: contentLabelTopMargin,
                                       width: textSize.width,
                                       height: textSize.height)
        } else {
            backgroundImageFrame = CGRect(x: width - bubbleMargin.leading - backgroundWidth,
                                          y: 0,
                                          width: backgroundWidth,
                                          height: contentSize.height + contentLabelTopMargin + contentMargin.bottom)
            contentLabelFrame = CGRect(x: ceil(backgroundImageFrame.origin.x + contentMargin.trailing),
                                       y: contentLabelTopMargin,
                                       width: textSize.width,
                                       height: textSize.height)
        }
        cellHeight = backgroundImageFrame.height + bottomSeparatorHeight
        layoutDetailInfo(backgroundImageFrame: backgroundImageFrame)
        if quotedMessageViewModel != nil && style.contains(.fullname) {
            backgroundImageFrame.origin.y += fullnameFrame.height
            backgroundImageFrame.size.height -= fullnameFrame.height
        }
        layoutQuotedMessageIfPresent()
    }
    
    func highlight(keyword: String) {
        guard let content = content else {
            return
        }
        let presentedContent = self.presentedContent as NSString
        var searchRange = NSRange(location: 0, length: presentedContent.length)
        var highlightRanges = [NSRange]()
        while searchRange.location < presentedContent.length {
            let foundRange = presentedContent.range(of: keyword, options: .caseInsensitive, range: searchRange)
            if foundRange.location != NSNotFound {
                highlightRanges.append(foundRange)
                searchRange.location = foundRange.location + foundRange.length
                searchRange.length = presentedContent.length - searchRange.location
            } else {
                break
            }
        }
        assert(content.lines.count == content.lineOrigins.count)
        for (i, line) in content.lines.enumerated() {
            let lineOrigin = content.lineOrigins[i]
            for highlightRange in highlightRanges {
                guard let highlightRect = line.frame(forRange: highlightRange, lineOrigin: lineOrigin) else {
                    continue
                }
                let path = UIBezierPath(roundedRect: highlightRect, cornerRadius: hightlightPathCornerRadius)
                highlightPaths.append(path)
            }
        }
    }
    
    func removeHighlights() {
        highlightPaths = []
    }
    
    func linkRanges(from string: String) -> [Link.Range] {
        var ranges = [Link.Range]()
        
        Link.detector.enumerateMatches(in: string, options: [], using: { (result, _, _) in
            guard let result = result, let url = result.url else {
                return
            }
            let range = Link.Range(range: result.range, url: url)
            ranges.append(range)
        })
        
        let str = string as NSString
        for mention in message.mentions ?? [:] {
            var searchingRange = NSRange(location: 0, length: str.length)
            var range: NSRange
            while searchingRange.location < str.length {
                range = str.range(of: "\(Mention.prefix)\(mention.value)", range: searchingRange)
                guard range.location != NSNotFound else {
                    break
                }
                let newSearchingLocation = NSMaxRange(range)
                let newSearchingLength = searchingRange.length - (newSearchingLocation - searchingRange.location)
                searchingRange = NSRange(location: newSearchingLocation, length: newSearchingLength)
                guard !ranges.contains(where: { $0.range.intersection(range) != nil }) else {
                    continue
                }
                guard let url = MixinInternalURL.identityNumber(mention.key).url else {
                    continue
                }
                let linkRange = Link.Range(range: range, url: url)
                ranges.append(linkRange)
            }
        }
        
        return ranges
    }
    
}
