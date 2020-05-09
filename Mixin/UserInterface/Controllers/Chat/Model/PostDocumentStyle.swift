import UIKit
import MixinServices
import Maaku
import TexturedMaaku

struct PostDocumentStyle: DocumentStyle {
    
    var insets: DocumentInsets = PostDocumentInsets()
    var colors: DocumentColors = PostColors()
    var values: DocumentValues = PostDocumentValues()
    var maakuStyle: Style = PostStyle()
    
}

extension PostDocumentStyle {
    
    private struct PostColors: DocumentColors {
        
        var background: UIColor = .background
        var blockQuoteLine: UIColor = .accessoryText
        var circleHeaderBackground: UIColor = .secondaryBackground
        var circleHeaderForeground: UIColor = .secondaryBackground
        var codeBlockBackground: UIColor = .secondaryBackground
        var horizontalRule: UIColor = .accessoryText
        
    }
    
    private struct PostColorStyle: ColorStyle {
        
        var current: Color = .text
        var h1: Color = .text
        var h2: Color = .text
        var h3: Color = .text
        var h4: Color = .text
        var h5: Color = .text
        var h6: Color = .text
        var inlineCodeForeground: Color = .text
        var inlineCodeBackground: Color = .secondaryBackground
        var link: Color = .theme
        var linkUnderline: Color = .clear
        var paragraph: Color = .text
        
    }
    
    private struct PostDocumentInsets: DocumentInsets {
        
        var document = UIEdgeInsets.zero
        var blockQuote = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        var codeBlock = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        var footNoteDefinition = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        var heading = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        var horizontalRule = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        var list = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        var paragraph = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        var table = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
    }
    
    private struct PostStyle: Style {
        
        var colors: ColorStyle = PostColorStyle()
        var fonts: FontStyle = DefaultFontStyle()
        var hasStrikethrough: Bool = false
        var softbreakSeparator: String = "\n"
        
    }
    
    private struct PostDocumentValues: DocumentValues {
        
        var blockQuoteLineWidth: CGFloat = 3.0
        var horizontalRuleHeight: CGFloat = 1
        var circleHeaderRadius: CGFloat = 15.5
        var circleHeaderFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .heavy)
        var unorderedListSymbol: String = "•"
        var circleHeadersEnabled: Bool = true
        var codeHighlighterTheme: String = UserInterfaceStyle.current == .dark ? "a11y-dark" : "a11y-light"
        var codeFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
        
    }
    
}
