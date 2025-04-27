// MARK: - FriendListCell.swift
import UIKit

class FriendListCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    // MARK: - Properties
    var removeAction: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureButton()
    }
    
    // MARK: - Configuration
    private func configureButton() {
        statusButton.layer.cornerRadius = 8
        statusButton.layer.borderWidth = 1
        statusButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"
        statusButton.setTitle("Added", for: .normal)
        statusButton.backgroundColor = .clear
        statusButton.setTitleColor(UIColor(hex: "#2727C4"), for: .normal)
    }
    
    // MARK: - Button Action
    @IBAction func removeTapped(_ sender: UIButton) {
        removeAction?()
    }
}
