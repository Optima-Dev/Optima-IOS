import UIKit

class FriendRequestCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var removeButton: UIButton! 
    
    var acceptAction: (() -> Void)?
    var declineAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set background color to light gray
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        // Apply corner radius to the cell
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        
        // Check if removeButton is connected
        if let removeButton = removeButton {
            // Apply border to remove button
            removeButton.layer.borderWidth = 2
            removeButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        } else {
            print("Remove button is not connected properly!")
        }
    }
    
    func configure(with request: FriendRequest) {
        let fullName = "\(request.firstName) \(request.lastName)"
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
        
        acceptButton.isHidden = false
        declineButton.isHidden = false
    }
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        acceptAction?()
    }
    
    @IBAction func declineTapped(_ sender: UIButton) {
        declineAction?()
    }
}
