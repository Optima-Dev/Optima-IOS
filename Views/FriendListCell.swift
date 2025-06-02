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
        setupButtonAppearance()
    }

    private func setupAvatar() {
        avatarImageView.image = UIImage(named: "friend")
        avatarImageView.contentMode = .scaleAspectFill
    }

    private func setupButtonAppearance() {
        statusButton.layer.cornerRadius = 12
        statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.backgroundColor = UIColor(hex: "#2727C4")
        statusButton.layer.borderWidth = 0
    }

    func configure(with friend: Friend) {
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"
        statusButton.setTitle("Added", for: .normal)
        statusButton.backgroundColor = UIColor(hex: "#2727C4")
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.layer.borderWidth = 0
    }

    @IBAction func removeTapped(_ sender: UIButton) {
        removeAction?()
    }
}
