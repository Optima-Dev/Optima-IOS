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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! // Added for loading indicator
    
    // MARK: - Properties
    private let mainColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
    private var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGestureRecognizers()
        setupTextFields()
        
        // Print the initial role for debugging
        let role = getSelectedRole()
        print("🔹 Initial role: \(role)")
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setBackgroundImage()
        setupButtons()
        errorLabel.isHidden = true
        activityIndicator.isHidden = true // Hide loading indicator initially
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
        let role = UserDefaults.standard.string(forKey: "userRole") ?? "helper"
        print("🔹 User selected role: \(role)")
        return role
    }
    
    // MARK: - Validation & Signup
    private func handleSignup() {
        dismissKeyboard()

        print("🔹 Signup button tapped")

        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }

        print("🔹 Validating user input")

        let firstNameValidation = validateName(firstName)
        let lastNameValidation = validateName(lastName)
        let emailValidation = validateEmail(email)
        let passwordValidation = validatePassword(password)

        if firstNameValidation.isValid &&
            lastNameValidation.isValid &&
            emailValidation.isValid &&
            passwordValidation.isValid {

            errorLabel.isHidden = true
            activityIndicator.isHidden = false // Show loading indicator
            activityIndicator.startAnimating()
            signUpButton.isEnabled = false // Disable signup button

            let role = getSelectedRole()
            print("🔹 Proceeding with signup for role: \(role)")

            AuthService.shared.signUpUser(firstName: firstName, lastName: lastName, email: email, password: password, role: role) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating() // Stop loading indicator
                    self.activityIndicator.isHidden = true // Hide loading indicator
                    self.signUpButton.isEnabled = true // Enable signup button

                    switch result {
                    case .success(let response):
                        if let token = response.token { // Success case (status 200)
                            self.handleSuccessfulSignup()
                        } else if let errorMessage = response.message { // Error case (status 400)
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
            print("🔴 Validation failed")
            handleValidationErrors(
                firstNameError: firstNameValidation.error,
                lastNameError: lastNameValidation.error,
                emailError: emailValidation.error,
                passwordError: passwordValidation.error
            )
        }
    }
    private func handleSuccessfulSignup() {
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            print("✅ Signup Successful, Token: \(token)")
            
            // Get the selected role
            let role = getSelectedRole()
            
            // Navigate to the appropriate screen based on the role
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if role == "helper" {
                // Navigate to VolunteerHomeViewController
                if let volunteerHomeVC = storyboard.instantiateViewController(withIdentifier: "VolunteerHomeViewController") as? VolunteerHomeViewController {
                    volunteerHomeVC.modalPresentationStyle = .fullScreen
                    self.present(volunteerHomeVC, animated: true, completion: nil)
                }
            } else if role == "seeker" {
                // Navigate to BlindHomeViewController
                if let blindHomeVC = storyboard.instantiateViewController(withIdentifier: "BlindHomeViewController") as? BlindHomeViewController {
                    blindHomeVC.modalPresentationStyle = .fullScreen
                    self.present(blindHomeVC, animated: true, completion: nil)
                }
            }
        } else {
            print("✅ Signup Successful, but no token received")
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
