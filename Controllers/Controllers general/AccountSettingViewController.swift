import UIKit

class AccountSettingViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTextFields()
        setupEditButton()
        loadUserData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Setup Background
    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    // MARK: - Setup TextFields
    private func setupTextFields() {
        configureTextField(firstNameTextField, icon: "personIcon", placeholder: "First Name")
        configureTextField(lastNameTextField, icon: "personIcon", placeholder: "Last Name")
        configureTextField(emailTextField, icon: "mail", placeholder: "Email")
        
        [firstNameTextField, lastNameTextField, emailTextField].forEach {
            $0?.isEnabled = false
        }
    }

    private func setupEditButton() {
        editButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        editButton.layer.borderWidth = 4
        editButton.layer.cornerRadius = 20
    }

    private func configureTextField(_ textField: UITextField, icon: String, placeholder: String) {
        let iconView = UIImageView(image: UIImage(named: icon))
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 12, y: 0, width: 24, height: 24)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        containerView.addSubview(iconView)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 20
    }

    // MARK: - Load User Data
    private func loadUserData() {
        UserManager.shared.fetchCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.firstNameTextField.text = user.firstName
                    self?.lastNameTextField.text = user.lastName
                    self?.emailTextField.text = user.email
                case .failure(let error):
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Edit Button Action
    @IBAction func editButtonTapped(_ sender: UIButton) {
        print("🟢 Navigating to Edit Profile") // ✅ Debugging to confirm navigation
        // The segue in Storyboard will handle the navigation
    }
}
