import UIKit

class SignupViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Properties
    private let mainColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
    private var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGestureRecognizers()
        setupTextFields()
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setBackgroundImage()
        setupButtons()
        errorLabel.isHidden = true
    }
    
    private func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupTextFields() {
        configureTextField(firstNameTextField, icon: "personIcon", placeholder: "First Name")
        configureTextField(lastNameTextField, icon: "personIcon", placeholder: "Last Name")
        configureTextField(emailTextField, icon: "mail", placeholder: "Email")
        configurePasswordTextField()
    }
    
    private func configurePasswordTextField() {
        configureTextField(passwordTextField, icon: "pass", placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        addPasswordToggleButton()
    }
    
    private func configureTextField(_ textField: UITextField, icon: String, placeholder: String) {
        let iconView = UIImageView(image: UIImage(named: icon))
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 12, y: 0, width: 24, height: 24)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        containerView.addSubview(iconView)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.layer.borderColor = mainColor.cgColor
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
    
    private func setupButtons() {
        signUpButton.layer.cornerRadius = 20
        googleLoginButton.layer.cornerRadius = 20
        googleLoginButton.layer.borderWidth = 2
        googleLoginButton.layer.borderColor = mainColor.cgColor
    }
    
    // MARK: - Actions
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        handleSignup()
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        sender.isSelected = isPasswordVisible
        passwordTextField.isSecureTextEntry = !isPasswordVisible
    }
    
    // MARK: - Validation Logic
    private func validateName(_ name: String) -> (isValid: Bool, error: String?) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return (false, "Name cannot be empty") }
        guard trimmedName.count >= 2 else { return (false, "Name must be at least 2 characters") }
        return (true, nil)
    }
    
    private func validateEmail(_ email: String) -> (isValid: Bool, error: String?) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        return isValid ? (true, nil) : (false, "Invalid email format")
    }
    
    private func validatePassword(_ password: String) -> (isValid: Bool, error: String?) {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        return isValid ? (true, nil) : (false, "Password must contain:\n- 8+ characters\n- 1 number\n- 1 special character")
    }
    
    private func handleSignup() {
        dismissKeyboard()
        
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        let firstNameValidation = validateName(firstName)
        let lastNameValidation = validateName(lastName)
        let emailValidation = validateEmail(email)
        let passwordValidation = validatePassword(password)
        
        if firstNameValidation.isValid &&
            lastNameValidation.isValid &&
            emailValidation.isValid &&
            passwordValidation.isValid {
            errorLabel.isHidden = true
            handleSuccessfulSignup()
        } else {
            handleValidationErrors(
                firstNameError: firstNameValidation.error,
                lastNameError: lastNameValidation.error,
                emailError: emailValidation.error,
                passwordError: passwordValidation.error
            )
        }
    }
    
    private func handleValidationErrors(firstNameError: String?,
                                        lastNameError: String?,
                                        emailError: String?,
                                        passwordError: String?) {
        var errorMessages = [String]()
        
        [firstNameError, lastNameError, emailError, passwordError].forEach {
            if let error = $0 { errorMessages.append("• \(error)") }
        }
        
        errorLabel.text = errorMessages.joined(separator: "\n\n")
        errorLabel.isHidden = false
        
        // Highlight invalid fields
        highlightField(firstNameTextField, isValid: firstNameError == nil)
        highlightField(lastNameTextField, isValid: lastNameError == nil)
        highlightField(emailTextField, isValid: emailError == nil)
        highlightField(passwordTextField, isValid: passwordError == nil)
    }
    
    private func highlightField(_ textField: UITextField, isValid: Bool) {
        textField.layer.borderColor = isValid ? mainColor.cgColor : UIColor.red.cgColor
    }
    
    // MARK: - Navigation
    private func handleSuccessfulSignup() {
        print("✅ Signup Successful")
        let userRole = UserDefaults.standard.string(forKey: "userRole") ?? "Blind"
        userRole == "Blind" ? navigateToBlindHome() : navigateToVolunteerHome()
    }
    
    private func navigateToBlindHome() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "BlindHomeViewController") else {
            showViewControllerError()
            return
        }
        presentFullScreen(vc)
    }
    
    private func navigateToVolunteerHome() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "VolunteerHomeViewController") else {
            showViewControllerError()
            return
        }
        presentFullScreen(vc)
    }
    
    private func presentFullScreen(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    // MARK: - Error Handling
    private func showViewControllerError() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load view controller",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Utilities
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension SignupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        highlightField(textField, isValid: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            handleSignup()
        default:
            break
        }
        return true
    }
}
