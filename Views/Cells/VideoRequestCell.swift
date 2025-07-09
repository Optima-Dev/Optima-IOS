import UIKit

class VideoRequestCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!

    var acceptAction: (() -> Void)?
    var declineAction: (() -> Void)?

    private var alreadyHandled = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        styleDeclineButton()

        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
    }

    func configure(with request: PendingMeeting) {
        alreadyHandled = false

        let name = request.seekerName ?? "Unknown"
        let message = " wants your help via video call."

        let attributed = NSMutableAttributedString(string: name, attributes: [.font: UIFont.boldSystemFont(ofSize: nameLabel.font.pointSize)])
        attributed.append(NSAttributedString(string: message, attributes: [.font: UIFont.systemFont(ofSize: nameLabel.font.pointSize)]))

        nameLabel.attributedText = attributed
        iconImageView.image = UIImage(named: "vidReq")

        showDefaultStyle()
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
        acceptAction?()
    }

    @IBAction func declineTapped(_ sender: UIButton) {
        guard !alreadyHandled else { return }
        alreadyHandled = true
        declineAction?()
    }
}
