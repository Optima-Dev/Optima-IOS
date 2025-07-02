import UIKit
import GoogleSignIn

class SignupViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let mainColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
    private var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGestureRecognizers()
        setupTextFields()
        print("🔹 Initial role: \(getSelectedRole())")
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setBackgroundImage()
        setupButtons()
        errorLabel.isHidden = true
        activityIndicator.isHidden = true
    }
    
    private func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
    
    // في SignupViewController.swift
    @IBAction func googleLoginButtonTapped(_ sender: UIButton) {
        GoogleAuthService.shared.signIn(with: self) { [weak self] result in
            switch result {
            case .success(let user):
                GoogleAuthService.shared.sendUserDataToAPI(user: user) { apiResult in
                    DispatchQueue.main.async {
                        switch apiResult {
                        case .success(let response):
                            if let token = response.token {
                                UserDefaults.standard.set(token, forKey: "authToken")
                                let role = UserDefaults.standard.string(forKey: "userRole") ?? "helper"
                                self?.handleSuccessfulSignup(role: role)
                            } else {
                                self?.showError(message: response.message ?? "Unknown error")
                            }
                        case .failure(let error):
                            self?.showError(message: error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                self?.showError(message: "Failed to sign in with Google: \(error.localizedDescription)")
            }
        }
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
    
    // MARK: - Role Handling
    private func getSelectedRole() -> String {
        UserDefaults.standard.string(forKey: "userRole") ?? "helper"
    }
    
    // MARK: - Validation & Signup
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
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            signUpButton.isEnabled = false

            let role = getSelectedRole()

            AuthService.shared.signUpUser(firstName: firstName, lastName: lastName, email: email, password: password, role: role) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.signUpButton.isEnabled = true

                    switch result {
                    case .success(let response):
                        if let token = response.token {
                            self.handleSuccessfulSignup(role: role)
                        } else if let errorMessage = response.message {
                            self.showError(message: errorMessage)
                        }
                    case .failure(let error):
                        self.showError(message: error.localizedDescription)
                    }
                }
            }
        } else {
            handleValidationErrors(
                firstNameError: firstNameValidation.error,
                lastNameError: lastNameValidation.error,
                emailError: emailValidation.error,
                passwordError: passwordValidation.error
            )
        }
    }
    
    private func handleSuccessfulSignup(role: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if role == "helper" {
            if let volunteerHomeVC = storyboard.instantiateViewController(withIdentifier: "VolunteerHomeViewController") as? VolunteerHomeViewController {
                volunteerHomeVC.modalPresentationStyle = .fullScreen
                self.present(volunteerHomeVC, animated: true)
            }
        } else if role == "seeker" {
            if let blindHomeVC = storyboard.instantiateViewController(withIdentifier: "BlindHomeViewController") as? BlindHomeViewController {
                blindHomeVC.modalPresentationStyle = .fullScreen
                self.present(blindHomeVC, animated: true)
            }
        }
    }
    
    private func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.errorLabel.isHidden = true
        }
    }
    
    private func handleValidationErrors(firstNameError: String?,
                                        lastNameError: String?,
                                        emailError: String?,
                                        passwordError: String?) {
        var errorMessages = [String]()
        
        if let error = firstNameError { errorMessages.append("• \(error)") }
        if let error = lastNameError { errorMessages.append("• \(error)") }
        if let error = emailError { errorMessages.append("• \(error)") }
        if let error = passwordError { errorMessages.append("• \(error)") }
        
        errorLabel.text = errorMessages.joined(separator: "\n\n")
        errorLabel.isHidden = false

        highlightField(firstNameTextField, isValid: firstNameError == nil)
        highlightField(lastNameTextField, isValid: lastNameError == nil)
        highlightField(emailTextField, isValid: emailError == nil)
        highlightField(passwordTextField, isValid: passwordError == nil)
    }

    private func highlightField(_ textField: UITextField, isValid: Bool) {
        textField.layer.borderColor = isValid ? mainColor.cgColor : UIColor.red.cgColor
    }
}
