import UIKit

protocol FriendCellDelegate: AnyObject {
    func didTapEditButton(for friend: Friend)
}

class FriendCell: UITableViewCell {
    @IBOutlet weak var firstLetterLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cellView: UIView!

    weak var delegate: FriendCellDelegate?
    private var friend: Friend?

    func configure(with friend: Friend) {
        self.friend = friend

        firstLetterLabel.text = String(friend.firstName.prefix(1)).uppercased()
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"

        setupFirstLetterLabel()
        setupCellView()
    }

    private func setupFirstLetterLabel() {
        firstLetterLabel.layer.cornerRadius = 8
        firstLetterLabel.layer.masksToBounds = true
        firstLetterLabel.textColor = .white
        firstLetterLabel.textAlignment = .center
        firstLetterLabel.font = UIFont.boldSystemFont(ofSize: 18)
    }

    private func setupCellView() {
        cellView.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        cellView.layer.borderWidth = 1
        cellView.layer.cornerRadius = 8
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        if let friend = friend {
            delegate?.didTapEditButton(for: friend)
        }
    }
}

extension UIColor {
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hexCode.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
