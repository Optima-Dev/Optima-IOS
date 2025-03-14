import UIKit

protocol FriendCellDelegate: AnyObject {
    func didTapEditButton(for friend: Friend)
}

class FriendCell: UITableViewCell {
    @IBOutlet weak var firstLetterLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    weak var delegate: FriendCellDelegate?
    private var friend: Friend?

    func configure(with friend: Friend) {
        self.friend = friend
        firstLetterLabel.text = String(friend.firstName.prefix(1)).uppercased()
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        if let friend = friend {
            delegate?.didTapEditButton(for: friend)
        }
    }
}
