import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()
        setupTextFields()
        setupButtons()
        errorLabel.isHidden = true
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Methods
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

    func setupTextFields() {
        configureTextField(emailTextField, withIcon: "mail", placeholder: "example@gmail.com")
        configureTextField(passwordTextField, withIcon: "pass", placeholder: "******")
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
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        textField.delegate = self // Assign delegate to self
    }

    func setupButtons() {
        loginButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 20.0
        
        googleLoginButton.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        googleLoginButton.layer.borderWidth = 2.0
        googleLoginButton.layer.cornerRadius = 20.0
        googleLoginButton.setTitleColor(UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1), for: .normal)
    }

    // MARK: - Action Methods
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            let (isEmailValid, emailError) = validateEmail(email)
            let (isPasswordValid, passwordError) = validatePassword(password)
            
            if isEmailValid && isPasswordValid {
                errorLabel.isHidden = true
                performLogin(email: email, password: password)
            } else {
                showError(emailError, passwordError)
            }
        }
    }

    func showError(_ emailError: String?, _ passwordError: String?) {
        var errorMessage = ""
        if let emailError = emailError {
            errorMessage += emailError + "\n"
        }
        if let passwordError = passwordError {
            errorMessage += passwordError
        }
        errorLabel.text = errorMessage
        errorLabel.isHidden = false
    }

    // MARK: - Validation Methods
    func validateEmail(_ email: String) -> (Bool, String?) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            return (false, "Invalid email: should include @")
        }
        return (true, nil)
    }

    func validatePassword(_ password: String) -> (Bool, String?) {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if !passwordPredicate.evaluate(with: password) {
            return (false, "Password must be at least 8 characters, contain a number and a symbol")
        }
        return (true, nil)
    }

    func performLogin(email: String, password: String) {
        // Networking logic goes here
        print("Email: \(email), Password: \(password)")
        
        // Navigate to the next screen (for now, just an example)
        performSegue(withIdentifier: "goToHome", sender: self)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    // Called when the user begins editing the text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Optionally you can add logic when the text field begins editing
        textField.layer.borderColor = UIColor.blue.cgColor // Adjust border color when editing begins
    }
    
    // Called when the user ends editing the text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Reset the border color once editing ends
        textField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
    }
    
    // Called when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when the user presses return
        textField.resignFirstResponder()
        return true
    }
}
