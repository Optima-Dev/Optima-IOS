import UIKit

class ProfileEditViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTextFields()
        loadUserData()

        // Ensure the Tab Bar remains visible when navigating
        self.hidesBottomBarWhenPushed = false

        // Dismiss keyboard when tapping outside any TextField
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // Assign delegate to text fields
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure the Tab Bar is visible when returning to this screen
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Dismiss Keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
    }

    private func configureTextField(_ textField: UITextField, icon: String, placeholder: String) {
        let iconView = UIImageView(image: UIImage(named: icon))
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 12, y: 0, width: 24, height: 24)

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        containerView.addSubview(iconView)

        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 20
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
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
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Save Button Action
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismissKeyboard()

        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "All fields must be filled.")
            return
        }

        UserManager.shared.updateUser(firstName: firstName, lastName: lastName, email: email) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Prevent duplicate alerts
                if self.presentedViewController is UIAlertController { return }

                switch result {
                case .success:
                    self.showAlert(title: "Success", message: "Profile updated successfully") {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Delete Account Button Action
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        dismissKeyboard()

        // Show confirmation alert before deleting
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.confirmDeleteAccount()
        }))

        present(alert, animated: true)
    }

    // MARK: - Confirm Account Deletion
    private func confirmDeleteAccount() {
        UserManager.shared.deleteUser { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Prevent duplicate alerts
                if self.presentedViewController is UIAlertController { return }

                switch result {
                case .success:
                    AuthManager.shared.clearAuthData()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let roleVC = storyboard.instantiateViewController(withIdentifier: "ChooseRoleViewController")
                    self.view.window?.rootViewController = roleVC
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
