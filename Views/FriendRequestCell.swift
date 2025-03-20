import UIKit

class FriendRequestCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    // MARK: - Callbacks
    var acceptAction: (() -> Void)?
    var removeAction: (() -> Void)?
    
    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetButtons()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none // ✅ Prevent background color change on tap
        
        contentView.backgroundColor = UIColor(hex: "#3C3C3C") // ✅ Ensure background stays fixed
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
        
        // Button Styling
        acceptButton.layer.cornerRadius = 10
        removeButton.layer.cornerRadius = 10
        removeButton.layer.borderWidth = 2
        removeButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
    }
    
    private func resetButtons() {
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = UIColor(hex: "#2727C4")
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.isEnabled = true
        
        removeButton.setTitle("Remove", for: .normal)
        removeButton.setTitleColor(UIColor(hex: "#2727C4"), for: .normal)
        removeButton.layer.borderWidth = 2
        removeButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        removeButton.backgroundColor = .clear
        removeButton.isEnabled = true
        removeButton.isHidden = false
    }
    
    // MARK: - Configuration
    func configureCell(with name: String, isAccepted: Bool) {
        setMessageLabel(for: name)
        
        if isAccepted {
            configureAcceptedState()
        } else {
            configureDefaultState()
        }
        
        // Attach button actions
        acceptButton.removeTarget(self, action: nil, for: .allEvents) // ✅ Prevent duplicate actions
        removeButton.removeTarget(self, action: nil, for: .allEvents)
        
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
    }
    
    private func setMessageLabel(for name: String) {
        let fullText = "\(name) added you as a friend."
        let attributedText = NSMutableAttributedString(string: fullText)
        
        if let userNameRange = fullText.range(of: name) {
            let nsRange = NSRange(userNameRange, in: fullText)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: nsRange)
        }
        
        let restOfTextRange = NSRange(location: name.count, length: fullText.count - name.count)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .light), range: restOfTextRange)
        
        messageLabel.attributedText = attributedText
    }
    
    private func configureAcceptedState() {
        acceptButton.setTitle("Accepted", for: .normal)
        acceptButton.backgroundColor = UIColor(hex: "#2727C4")
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.isEnabled = false
        
        removeButton.isHidden = true
    }
    
    private func configureDefaultState() {
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = UIColor(hex: "#2727C4")
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.isEnabled = true
        
        removeButton.isHidden = false
    }
    
    // MARK: - Button Actions
    @objc private func acceptTapped() {
        acceptAction?()
    }
    
    @objc private func removeTapped() {
        print("Remove button tapped!") // Debugging print
        
        // ✅ Fix: Update UI on the main thread immediately
        self.removeButton.setTitle("Removed", for: .normal)
        self.removeButton.setTitleColor(UIColor(hex: "#2727C4"), for: .normal)
        self.removeButton.layer.borderWidth = 2
        self.removeButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        self.removeButton.backgroundColor = .clear
        self.removeButton.isEnabled = false // Disable button after tapping
        
        removeAction?()
    }
}
