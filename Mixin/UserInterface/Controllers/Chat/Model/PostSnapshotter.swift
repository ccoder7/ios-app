import UIKit
import AsyncDisplayKit
import Maaku
import TexturedMaaku

class PostSnapshotter {
    
    let markdown: String
    
    init(markdown: String) {
        self.markdown = markdown
    }
    
    func make() -> UIImage? {
        guard let document = try? Document(text: markdown) else {
            return nil
        }
        guard let root = UIApplication.homeNavigationController else {
            return nil
        }
        let style = PostDocumentStyle()
        let controller = SynchornousDocumentViewController(document: document, style: style)
        root.addChild(controller)
        root.view.insertSubview(controller.view, at: 0)
        controller.view.snp.makeConstraints { (make) in
            make.edges.equalTo(root.view.safeAreaLayoutGuide)
        }
        controller.didMove(toParent: root)
        var contentSize = controller.node.collectionNode.view.contentSize
        contentSize.height = min(controller.view.frame.height, contentSize.height)
        let renderer = UIGraphicsImageRenderer(size: contentSize)
        let image = renderer.image { (ctx) in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
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
        
        public var documentStyle: DocumentStyle {
            didSet {
                node.documentStyle = documentStyle
            }
        }
        
        public init(document: Document, style: DocumentStyle = DefaultDocumentStyle()) {
            self.documentStyle = style
            super.init(node: SynchornousDocumentNode(document: document, style: style))
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            documentStyle = PostDocumentStyle()
        }
        
        open func reload() {
            node.reload()
        }
        
    }
    
}
