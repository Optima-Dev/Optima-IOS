import UIKit

class SettingForBlindViewController: SeekerBaseViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch! // Reference to the Dark Mode switch

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }

    // Set the background image of the screen
    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    // Load current user info (name and email)
    private func loadUserData() {
        UserManager.shared.fetchCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("🟢 User Data Loaded: \(user.firstName) \(user.lastName), \(user.email)")
                    self?.userNameLabel.text = "\(user.firstName) \(user.lastName)"
                    self?.emailLabel.text = user.email
                case .failure(let error):
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            }
        }
    }

    // Called when the Dark Mode switch is toggled
    @IBAction func darkModeSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            // Show a pop-up indicating the feature is coming soon
            let alert = UIAlertController(
                title: "Coming Soon",
                message: "Dark Mode feature is coming soon!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)

            // Turn the switch back to OFF
            sender.setOn(false, animated: true)
        }
    }
}
