import UIKit

protocol FriendCellDelegate: AnyObject {
    func didTapEditButton(for friend: Friend)
}

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var firstLetterLabel: UILabel!
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
        firstLetterLabel.text = String(friend.firstName.prefix(1)).uppercased()
    }
    
    private func setupUI() {
        // Container view border and radius
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        containerView.backgroundColor = UIColor.white
        
        // Badge image setup
        badgeImageView.image = UIImage(named: "intialBadge")
        badgeImageView.contentMode = .scaleAspectFill
        badgeImageView.layer.cornerRadius = 8
        badgeImageView.clipsToBounds = true
        
        // Letter setup
        firstLetterLabel.textColor = .white
        firstLetterLabel.font = .boldSystemFont(ofSize: 24)
        firstLetterLabel.textAlignment = .center
        firstLetterLabel.backgroundColor = .clear
        
        // Edit button image setup
        editButton.setImage(UIImage(named: "edit"), for: .normal)
        editButton.tintColor = UIColor(hex: "#2727C4")
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard let friend = currentFriend else { return }
        delegate?.didTapEditButton(for: friend)
    }
}
