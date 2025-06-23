import UIKit

class FriendRequestCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!

    var acceptAction: (() -> Void)?
    var declineAction: (() -> Void)?
    
    // Flag to prevent repeated clicks
    private var alreadyHandled = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        styleDeclineButton()

        // Allow multiline message to appear properly
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
    }

    func configure(with request: FriendRequest, isAccepted: Bool, isRejected: Bool) {
        alreadyHandled = isAccepted || isRejected

        //  Fix invalid/missing names fallback
        let firstName = request.firstName.isEmpty ? "Unknown" : request.firstName
        let lastName = request.lastName.isEmpty ? "" : request.lastName
        let fullName = "\(firstName) \(lastName)"
        let message = " added you as a friend."

        let attributedText = NSMutableAttributedString(
            string: fullName,
            attributes: [.font: UIFont.boldSystemFont(ofSize: nameLabel.font.pointSize)]
        )
        attributedText.append(NSAttributedString(
            string: message,
            attributes: [.font: UIFont.systemFont(ofSize: nameLabel.font.pointSize)]
        ))
        nameLabel.attributedText = attributedText

        if isAccepted {
            showAcceptedStyle()
        } else if isRejected {
            showRejectedStyle()
        } else {
            showDefaultStyle()
        }
    }

    private func showAcceptedStyle() {
        acceptButton.setTitle("Accepted", for: .normal)
        acceptButton.backgroundColor = UIColor(hex: "#2727C4")
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 10
        acceptButton.isEnabled = false
        declineButton.isHidden = true
    }

    private func showRejectedStyle() {
        declineButton.setTitle("Rejected", for: .normal)
        declineButton.backgroundColor = UIColor(hex: "#2727C4")
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.layer.cornerRadius = 10
        declineButton.isEnabled = false
        acceptButton.isHidden = true
    }

    private func showDefaultStyle() {
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = UIColor(hex: "#2727C4")
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.isEnabled = true
        acceptButton.isHidden = false

        declineButton.setTitle("Decline", for: .normal)
        styleDeclineButton()
        declineButton.isEnabled = true
        declineButton.isHidden = false
    }

    private func styleDeclineButton() {
        declineButton.layer.borderWidth = 2
        declineButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        declineButton.backgroundColor = .clear
        declineButton.setTitleColor(UIColor(hex: "#2727C4"), for: .normal)
        declineButton.layer.cornerRadius = 10
    }

    @IBAction func acceptTapped(_ sender: UIButton) {
        guard !alreadyHandled else { return }
        alreadyHandled = true
        acceptButton.isEnabled = false
        acceptAction?()
    }

    @IBAction func declineTapped(_ sender: UIButton) {
        guard !alreadyHandled else { return }
        alreadyHandled = true
        declineButton.isEnabled = false
        declineAction?()
    }
}
