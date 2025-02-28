import UIKit

class ConfirmPasswordViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var successPopup: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var topview: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    private var isPasswordVisible = false
    var userEmail: String? //  EnterCodeViewController for email

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()
        setupTextFields()
        setupButtons()
        
        successPopup.isHidden = true
        dimmingView.isHidden = true
        errorLabel.isHidden = true
        activityIndicator.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Background Setup
    func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Text Field Setup
    func setupTextFields() {
        configureTextField(passwordTextField, withIcon: "pass", placeholder: "******")
        addPasswordToggleButton()
    }

    func configureTextField(_ textField: UITextField, withIcon iconName: String, placeholder: String) {
        let icon = UIImageView(image: UIImage(named: iconName))
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        iconContainer.addSubview(icon)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
        textField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        textField.layer.borderWidth = 2.0
        textField.layer.cornerRadius = 20.0
        textField.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        textField.isSecureTextEntry = true
    }

    private func addPasswordToggleButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pass1"), for: .normal)
        button.setImage(UIImage(named: "eyepass"), for: .selected)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 24))
        containerView.addSubview(button)
        
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        sender.isSelected = isPasswordVisible
        passwordTextField.isSecureTextEntry = !isPasswordVisible
    }

    // MARK: - Button Setup
    func setupButtons() {
        resetButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 20.0
        
        doneButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 20.0
    }

    // MARK: - Reset Button Action
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        guard let newPassword = passwordTextField.text, !newPassword.isEmpty else {
            showError(message: "Please enter a new password")
            return
        }
        
        guard let userEmail = userEmail, !userEmail.isEmpty else {
            showError(message: "Email is missing. Please try again.")
            return
        }
        
        let (isValid, errorMessage) = validatePassword(newPassword)
        
        if isValid {
            passwordTextField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
            errorLabel.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            resetButton.isEnabled = false
            
            ResetPasswordService.shared.resetPassword(email: userEmail, newPassword: newPassword) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.resetButton.isEnabled = true
                    
                    switch result {
                    case .success(let response):
                        if response.message == "Password reset successfully" {
                            self.showSuccessPopup()
                        } else {
                            self.showError(message: response.message ?? "Unknown error occurred")
                        }
                    case .failure(let error):
                        self.showError(message: error.localizedDescription)
                    }
                }
            }
        } else {
            showError(message: errorMessage ?? "Invalid password")
        }
    }

    // MARK: - Password Validation
    private func validatePassword(_ password: String) -> (Bool, String?) {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        
        return isValid ? (true, nil) : (false, "Password must contain:\n- 8+ characters\n- 1 number\n- 1 special character")
    }

    // MARK: - Error Handling
    private func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        passwordTextField.layer.borderColor = UIColor.red.cgColor
    }

    // MARK: - Success Handling
    private func showSuccessPopup() {
        successPopup.isHidden = false
        dimmingView.isHidden = false
        dimmingView.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
    }

    // MARK: - Done Button Action
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        successPopup.isHidden = true
        dimmingView.isHidden = true
        performSegue(withIdentifier: "goToLogin", sender: self)
    }

    // MARK: - Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - View Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maskPath = UIBezierPath(
            roundedRect: topview.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = maskPath.cgPath
        topview.layer.mask = shapeLayer
    }
}
