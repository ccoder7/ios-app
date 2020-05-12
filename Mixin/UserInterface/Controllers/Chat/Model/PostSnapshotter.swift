import UIKit
import AsyncDisplayKit
import Maaku
import TexturedMaaku

class PostSnapshotter {
    
    let markdown: String
    
    init(markdown: String) {
        self.markdown = markdown
    }
    
    func make(width: CGFloat, style: UserInterfaceStyle) -> UIImage? {
        guard let navigationController = UIApplication.homeNavigationController, !navigationController.isTransitioning else {
            // Mounting views into window while navigation controller
            // is transitioning makes the animation flickers
            return nil
        }
        guard let document = try? Document(text: markdown) else {
            return nil
        }
        guard let parent = UIApplication.homeContainerViewController else {
            return nil
        }
        let documentStyle = PostDocumentStyle()
        let controller = SynchornousDocumentViewController(document: document, style: documentStyle)
        if #available(iOS 13.0, *) {
            controller.overrideUserInterfaceStyle = style.uiUserInterfaceStyle
        }
        parent.addChild(controller)
        parent.view.insertSubview(controller.view, at: 0)
        let canvasWidth = width + documentStyle.insets.paragraph.horizontal
        controller.view.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalTo(parent.view.safeAreaLayoutGuide)
            make.width.equalTo(canvasWidth)
        }
        controller.didMove(toParent: parent)
        parent.view.layoutIfNeeded()
        var contentSize = controller.node.collectionNode.view.contentSize
        contentSize.height = min(controller.view.frame.height, contentSize.height)
        let renderer = UIGraphicsImageRenderer(size: contentSize)
        let image = renderer.image { (ctx) in
            let canvas = CGRect(x: -documentStyle.insets.paragraph.left,
                                y: -documentStyle.insets.paragraph.top,
                                width: controller.view.bounds.width,
                                height: controller.view.bounds.height)
            controller.view.drawHierarchy(in: canvas, afterScreenUpdates: true)
        }
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        return image
    }
    
}

extension PostSnapshotter {
    
    private class SynchornousDocumentNode: DocumentNode {
        
        override func setupCollectionView() {
            super.setupCollectionView()
            collectionNode.view.backgroundColor = .clear
        }
        
        override func collectionView(_ collectionView: ASCollectionView, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
            let node = super.collectionView(collectionView, nodeForItemAt: indexPath)
            node.neverShowPlaceholders = true
            return node
        }
        
    }
    
    private class SynchornousDocumentViewController: ASViewController<SynchornousDocumentNode> {
        
        var documentStyle: DocumentStyle {
            didSet {
                node.documentStyle = documentStyle
            }
        }
        
        init(document: Document, style: DocumentStyle = DefaultDocumentStyle()) {
            self.documentStyle = style
            super.init(node: SynchornousDocumentNode(document: document, style: style))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
        
        func reload() {
            node.reload()
        }
        
    }
    
}
