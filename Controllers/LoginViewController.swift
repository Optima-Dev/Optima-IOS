import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let mainColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
    private var isPasswordVisible = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGestureRecognizers()
        setupTextFieldsDelegates()
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setBackgroundImage()
        setupTextFields()
        setupButtons()
        errorLabel.isHidden = true
        activityIndicator.isHidden = true
    }
    
    private func setupTextFieldsDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupButtons() {
        loginButton.layer.cornerRadius = 20
        googleLoginButton.layer.cornerRadius = 20
        googleLoginButton.layer.borderWidth = 2
        googleLoginButton.layer.borderColor = mainColor.cgColor
    }
    
    private func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupTextFields() {
        configureEmailTextField()
        configurePasswordTextField()
    }
    
    private func configureEmailTextField() {
        configureTextField(emailTextField, icon: "mail", placeholder: "example@gmail.com")
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
    }
    
    private func configurePasswordTextField() {
        configureTextField(passwordTextField, icon: "pass", placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        addPasswordToggleButton()
        passwordTextField.returnKeyType = .go
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
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        handleLogin()
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        sender.isSelected = isPasswordVisible
        passwordTextField.isSecureTextEntry = !isPasswordVisible
    }
    
    // MARK: - Validation Logic
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func handleValidationErrors(emailValid: Bool, passwordValid: Bool) {
        resetTextField(emailTextField)
        resetTextField(passwordTextField)
        
        if !emailValid { showEmailError() }
        if !passwordValid { showPasswordError() }
    }
    
    private func showEmailError() {
        emailTextField.text = ""
        emailTextField.layer.borderColor = UIColor.red.cgColor
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Invalid email should contain @",
            attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }
    
    private func showPasswordError() {
        passwordTextField.text = ""
        passwordTextField.layer.borderColor = UIColor.red.cgColor
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Invalid password",
            attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }
    
    private func resetTextField(_ textField: UITextField) {
        textField.layer.borderColor = mainColor.cgColor
        textField.attributedPlaceholder = NSAttributedString(
            string: textField == emailTextField ? "Email" : "Password",
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }
    
 // MARK: - Navigation
     private func handleSuccessfulLogin(email: String, password: String) {
         if let token = UserDefaults.standard.string(forKey: "authToken") {
             print("✅ Login Successful, Token: \(token)")
             
             // Get the selected role
             let role = UserDefaults.standard.string(forKey: "userRole") ?? "helper"
             
             // Navigate to the appropriate screen based on the role
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             
             if role == "seeker" {
                 // Navigate to BlindHomeViewController
                 if let blindHomeVC = storyboard.instantiateViewController(withIdentifier: "BlindHomeViewController") as? BlindHomeViewController {
                     blindHomeVC.modalPresentationStyle = .fullScreen
                     self.present(blindHomeVC, animated: true, completion: nil)
                 }
             } else {
                 // Navigate to VolunteerHomeViewController
                 if let volunteerHomeVC = storyboard.instantiateViewController(withIdentifier: "VolunteerHomeViewController") as? VolunteerHomeViewController {
                     volunteerHomeVC.modalPresentationStyle = .fullScreen
                     self.present(volunteerHomeVC, animated: true, completion: nil)
                 }
             }
         } else {
             print("✅ Login Successful, but no token received")
         }
     }
    
    private func navigateToBlindHome() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "BlindHomeViewController") else {
            showViewControllerError()
            return
        }
        vc.modalPresentationStyle = .fullScreen //full screen
        present(vc, animated: true)
    }
    
    private func navigateToVolunteerHome() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "VolunteerHomeViewController") else {
            showViewControllerError()
            return
        }
        vc.modalPresentationStyle = .fullScreen //full screen
        present(vc, animated: true)
    }
    
    private func showViewControllerError() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load view controller",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func handleLogin() {
        dismissKeyboard()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        let isEmailValid = validateEmail(email)
        let isPasswordValid = validatePassword(password)
        
        if isEmailValid && isPasswordValid {
            errorLabel.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            loginButton.isEnabled = false

            LoginService.shared.loginUser(email: email, password: password) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.loginButton.isEnabled = true

                    switch result {
                    case .success(let response):
                        if let token = response.token {
                            self.handleSuccessfulLogin(email: email, password: password)
                        } else if let errorMessage = response.message {
                            print("🔴 Error: \(errorMessage)")
                            self.errorLabel.text = errorMessage
                            self.errorLabel.isHidden = false
                        }
                    case .failure(let error):
                        let errorMessage = error.localizedDescription
                        print("🔴 Error: \(errorMessage)")
                        self.errorLabel.text = errorMessage
                        self.errorLabel.isHidden = false
                    }
                }
            }
        } else {
            handleValidationErrors(emailValid: isEmailValid, passwordValid: isPasswordValid)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resetTextField(textField)
        textField.layer.borderColor = mainColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isValid = textField == emailTextField ?
            validateEmail(textField.text ?? "") :
            validatePassword(textField.text ?? "")
        
        textField.layer.borderColor = isValid ? mainColor.cgColor : UIColor.red.cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            handleLogin()
        default:
            break
        }
        return true
    }
}
