import UIKit

class FriendListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var isAdded = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        if let button = addButton {
            button.layer.cornerRadius = 10
        } else {
            print("❌ addButton is nil!")
        }
        
      
        self.backgroundColor = .clear
    }

    func updateButtonState(isAdded: Bool) {
        self.isAdded = isAdded
        addButton.setTitle(isAdded ? "Added" : "Add", for: .normal)
        addButton.backgroundColor = isAdded ? .blue : .clear
        addButton.layer.borderColor = UIColor.blue.cgColor
        addButton.layer.borderWidth = isAdded ? 0 : 1
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        isAdded.toggle()
        updateButtonState(isAdded: isAdded)
    }
}
