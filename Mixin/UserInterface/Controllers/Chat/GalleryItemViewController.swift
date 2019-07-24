import UIKit

class GalleryItemViewController: UIViewController {
    
    let operationButton = NetworkOperationButton()
    let expiredHintLabel = UILabel()
    let mediaStatusView = UIStackView()
    
    var item: GalleryItem? {
        didSet {
            load(item: item)
        }
    }
    
    var isFocused = false
    
    var image: UIImage? {
        return nil
    }
    
    var isDownloadingAttachment: Bool {
        return false
    }
    
    var shouldDownloadAutomatically: Bool {
        return false
    }
    
    var galleryViewController: GalleryViewController? {
        return parent?.parent as? GalleryViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operationButton.addTarget(self, action: #selector(attachmentAction(_:)), for: .touchUpInside)
        expiredHintLabel.text = R.string.localizable.chat_file_expired()
        expiredHintLabel.font = .systemFont(ofSize: 13)
        expiredHintLabel.textColor = .white
        [operationButton, expiredHintLabel].forEach(mediaStatusView.addArrangedSubview)
        mediaStatusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mediaStatusView)
        mediaStatusView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            item = nil
            isFocused = false
        }
    }
    
    func prepareForReuse() {
        mediaStatusView.isHidden = true
        expiredHintLabel.isHidden = true
        operationButton.style = .finished(showPlayIcon: false)
    }
    
    func beginDownload() {
        
    }
    
    func cancelDownload() {
        
    }
    
    func set(thumbnail: GalleryItem.Thumbnail) {
        
    }
    
    func load(item: GalleryItem?) {
        guard let item = item else {
            return
        }
        set(thumbnail: item.thumbnail)
        if let mediaStatus = item.mediaStatus {
            layout(mediaStatus: mediaStatus)
        }
        if item.mediaStatus == .PENDING && shouldDownloadAutomatically {
            beginDownload()
        }
    }
    
    func saveToLibrary() {
        
    }
    
    func layout(mediaStatus: MediaStatus) {
        switch mediaStatus {
        case .PENDING:
            if isDownloadingAttachment {
                mediaStatusView.isHidden = false
                expiredHintLabel.isHidden = true
                operationButton.style = .busy(progress: 0)
            } else {
                fallthrough
            }
        case .CANCELED:
            mediaStatusView.isHidden = false
            expiredHintLabel.isHidden = true
            operationButton.style = .download
        case .DONE, .READ:
            mediaStatusView.isHidden = true
            expiredHintLabel.isHidden = true
            operationButton.style = .finished(showPlayIcon: false)
        case .EXPIRED:
            mediaStatusView.isHidden = false
            expiredHintLabel.isHidden = false
            operationButton.style = .expired
        }
    }
    
    @objc func attachmentAction(_ sender: Any) {
        if isDownloadingAttachment {
            cancelDownload()
        } else {
            beginDownload()
        }
    }
    
}
