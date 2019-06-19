import UIKit

class PrivacyViewController: UITableViewController {
    
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var emergencyLabel: UILabel!
    
    private let blockedUsersIndexPath = IndexPath(row: 0, section: 0)
    private let footerReuseId = "footer"
    
    private lazy var userWindow = UserWindow.instance()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    class func instance() -> UIViewController {
        let vc = R.storyboard.setting.privacy()!
        let container = ContainerViewController.instance(viewController: vc, title: Localized.SETTING_PRIVACY_AND_SECURITY)
        return container
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SeparatorShadowFooterView.self, forHeaderFooterViewReuseIdentifier: footerReuseId)
        tableView.estimatedSectionFooterHeight = 10
        tableView.sectionFooterHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(updateBlockedUserCell), name: .UserDidChange, object: nil)
        updateBlockedUserCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var vc: UIViewController!
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                vc = BlockUserViewController.instance()
            } else {
                vc = ConversationSettingViewController.instance()
            }
        case 1:
            vc = AuthorizationsViewController.instance()
        default:
            if let account = AccountAPI.shared.account, account.has_emergency_contact {
                let alc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alc.addAction(UIAlertAction(title: R.string.localizable.emergency_view(), style: .default, handler: {(_) in
                    self.viewEmergencyAction()
                }))
                alc.addAction(UIAlertAction(title: R.string.localizable.emergency_change(), style: .default, handler: {(_) in
                    self.changeEmergencyAction()
                }))
                alc.addAction(UIAlertAction(title: Localized.DIALOG_BUTTON_CANCEL, style: .cancel, handler: nil))
                self.present(alc, animated: true, completion: nil)
            } else {
                EmergencyWindow.instance().presentPopupControllerAnimated()
            }
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerReuseId) as! SeparatorShadowFooterView
        if section == 0 {
            view.text = Localized.SETTING_PRIVACY_AND_SECURITY_SUMMARY
        }
        view.shadowView.hasLowerShadow = section != numberOfSections(in: tableView) - 1
        return view
    }
    
    @objc func updateBlockedUserCell() {
        DispatchQueue.global().async {
            let blocked = UserDAO.shared.getBlockUsers()
            DispatchQueue.main.async { [weak self] in
                self?.blockLabel.text = blocked.count > 0 ? "\(blocked.count)" + Localized.SETTING_BLOCKED_USER_COUNT_SUFFIX : Localized.SETTING_BLOCKED_USER_COUNT_NONE
            }
        }
    }
    
    private func viewEmergencyAction() {
        let emergencyUserId = ""
        DispatchQueue.global().async { [weak self] in
            var emergencyUser = UserDAO.shared.getUser(userId: emergencyUserId)
            if emergencyUser == nil {
                switch UserAPI.shared.showUser(userId: emergencyUserId) {
                case let .success(user):
                    UserDAO.shared.updateUsers(users: [user])
                    emergencyUser = UserItem.createUser(from: user)
                case let .failure(error):
                    showAutoHiddenHud(style: .error, text: error.localizedDescription)
                    return
                }
            }
            DispatchQueue.main.async {
                guard let weakSelf = self, let user = emergencyUser else {
                    return
                }
                weakSelf.userWindow.updateUser(user: user)
                weakSelf.userWindow.presentView()
            }
        }
    }
    
    private func changeEmergencyAction() {
        guard let account = AccountAPI.shared.account else {
            return
        }
        if account.has_pin {
            let vc = EmergencyContactVerifyPinViewController()
            let navigationController = VerifyPinNavigationController(rootViewController: vc)
            present(navigationController, animated: true, completion: nil)
        } else {
            let vc = WalletPasswordViewController.instance(dismissTarget: .setEmergencyContact)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
