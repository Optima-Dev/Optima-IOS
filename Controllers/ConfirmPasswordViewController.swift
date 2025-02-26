import UIKit

class ConfirmPasswordViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var successPopup: UIView! // Pop-up view from storyboard
    @IBOutlet weak var doneButton: UIButton! // Done button in the pop-up
    @IBOutlet weak var dimmingView: UIView!  // Dimming view covering the background
    @IBOutlet weak var topview: UIView!  // The view where we want to apply corner radius

    // MARK: - Properties
    private var isPasswordVisible = false // Track password visibility state

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()
        setupTextFields()
        setupButtons()
        
        // Hide the success popup and dimming view initially
        successPopup.isHidden = true
        dimmingView.isHidden = true
        
        // Add tap gesture recognizer to dismiss keyboard
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
        addPasswordToggleButton() // Add eye button to toggle password visibility
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
        textField.isSecureTextEntry = true // Hide password by default
    }

    // MARK: - Add Eye Button to Toggle Password Visibility
    private func addPasswordToggleButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pass1"), for: .normal) // Closed eye icon
        button.setImage(UIImage(named: "eyepass"), for: .selected) // Open eye icon
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 24))
        containerView.addSubview(button)
        
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
    }

    // MARK: - Toggle Password Visibility
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
    }

    // MARK: - Reset Button Action
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        if let newPassword = passwordTextField.text {
            let (isPasswordValid, passwordError) = validatePassword(newPassword)

            if isPasswordValid {
                passwordTextField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
                passwordTextField.attributedPlaceholder = NSAttributedString(
                    string: "******",
                    attributes: [
                        .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                        .font: UIFont.systemFont(ofSize: 16)
                    ]
                )
                performResetPassword(newPassword: newPassword)
            } else {
                showError(passwordError)
            }
        }
    }

    // MARK: - Show Error Messages
    func showError(_ passwordError: String?) {
        // Change placeholder and border color to indicate error
        passwordTextField.layer.borderColor = UIColor.red.cgColor
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Invalid password",
            attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }

    // MARK: - Password Validation
    func validatePassword(_ password: String) -> (Bool, String?) {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if !passwordPredicate.evaluate(with: password) {
            return (false, "Password must be at least 8 characters, contain a number and a symbol")
        }
        return (true, nil)
    }

    // MARK: - Perform Password Reset
    func performResetPassword(newPassword: String) {
        // Networking logic goes here
        print("Password reset successfully: \(newPassword)")
        
        // Displaying the Success Pop-up
        showSuccessPopup()
    }

    // MARK: - Show Success Popup
    func showSuccessPopup() {
        // Make the success pop-up visible
        successPopup.isHidden = false
        
        // Show the dimming view with gray background
        dimmingView.isHidden = false
        dimmingView.backgroundColor = UIColor(white: 0.2, alpha: 0.7) // Gray with transparency
    }

    // MARK: - Done Button Action
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        // Dismiss the popup
        successPopup.isHidden = true
        
        // Hide the dimming view
        dimmingView.isHidden = true
        
        // Navigate to login screen
        performSegue(withIdentifier: "goToLogin", sender: self)
    }

    // MARK: - Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Apply Corner Radius to Popup
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Apply corner radius to the top corners only of the topview
        let path = UIBezierPath(
            roundedRect: topview.bounds,
            byRoundingCorners: [.topLeft, .topRight], // Top corners only
            cornerRadii: CGSize(width: 20, height: 20)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        topview.layer.mask = maskLayer
    }
}
