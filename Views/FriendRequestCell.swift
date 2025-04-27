import UIKit

class FriendRequestCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    var acceptAction: (() -> Void)?
    var declineAction: (() -> Void)?
    
    func configure(with request: FriendRequest) {
        nameLabel.text = "\(request.firstName) \(request.lastName)"
        
        //update status
        acceptButton.isHidden = (request.status != "pending")
        declineButton.isHidden = (request.status != "pending")
    }
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        acceptAction?()
    }
    
    @IBAction func declineTapped(_ sender: UIButton) {
        declineAction?()
    }
}
