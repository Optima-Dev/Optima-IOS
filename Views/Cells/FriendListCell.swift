import UIKit

class FriendListCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!

    var removeAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupAvatar()
        setupInitialButtonStyle()
    }

    // Set avatar image and content mode
    private func setupAvatar() {
        avatarImageView.image = UIImage(named: "friend")
        avatarImageView.contentMode = .scaleAspectFill
    }

    // Set base button style (font + corner radius only)
    private func setupInitialButtonStyle() {
        statusButton.layer.cornerRadius = 12
        statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    }

    // Configure UI based on friend state
    func configure(with friend: Friend) {
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"

        if friend.isAdded == true {
            // Style for "Added" state
            statusButton.setTitle("Added", for: .normal)
            statusButton.setTitleColor(.white, for: .normal)
            statusButton.backgroundColor = UIColor(hex: "#2727C4")
            statusButton.layer.borderWidth = 0
        } else {
            // Style for "Add" state
            statusButton.setTitle("Add", for: .normal)
            statusButton.setTitleColor(UIColor(hex: "#2727C4"), for: .normal)
            statusButton.backgroundColor = .clear
            statusButton.layer.borderWidth = 2
            statusButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        }
    }

    // Trigger remove action when button tapped
    @IBAction func removeTapped(_ sender: UIButton) {
        removeAction?()
    }
}
