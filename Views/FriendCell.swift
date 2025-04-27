import UIKit

protocol FriendCellDelegate: AnyObject {
    func didTapEditButton(for friend: Friend)
}

class FriendCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var initialsBadge: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    weak var delegate: FriendCellDelegate?
    private var currentFriend: Friend?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func configure(with friend: Friend) {
        currentFriend = friend
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"
        initialsBadge.text = String(friend.firstName.prefix(1)).uppercased()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1.5
        containerView.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        
        initialsBadge.layer.cornerRadius = 20
        initialsBadge.clipsToBounds = true
        initialsBadge.backgroundColor = UIColor(hex: "#2727C4")
        initialsBadge.textColor = .white
        initialsBadge.font = .boldSystemFont(ofSize: 18)
        
        editButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        editButton.tintColor = UIColor(hex: "#2727C4")
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard let friend = currentFriend else { return }
        delegate?.didTapEditButton(for: friend)
    }
}
