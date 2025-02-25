import UIKit

class ConfirmPasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var successPopup: UIView! // Pop-up view from storyboard
    @IBOutlet weak var doneButton: UIButton! // Done button in the pop-up
    @IBOutlet weak var dimmingView: UIView!  // Dimming view covering the background
    @IBOutlet weak var topview: UIView!  // The view where we want to apply corner radius

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

    // Background setup
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

    // Setup for password text field (same as Login's password text field)
    func setupTextFields() {
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
        textField.layer.cornerRadius = 20.0 // Make sure the radius is same as login
        textField.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1) // Same background as login
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }

    // Setup for reset button
    func setupButtons() {
        resetButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 20.0
    }

    // Action when reset button is pressed
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

    // Show error messages
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

    // Validate password (must contain at least 8 characters, one number, and one special character)
    func validatePassword(_ password: String) -> (Bool, String?) {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if !passwordPredicate.evaluate(with: password) {
            return (false, "Password must be at least 8 characters, contain a number and a symbol")
        }
        return (true, nil)
    }

    // Perform password reset action (here you can call the backend API for password reset)
    func performResetPassword(newPassword: String) {
        // Networking logic goes here
        print("Password reset successfully: \(newPassword)")
        
        // Displaying the Success Pop-up
        showSuccessPopup()
    }

    // Show success popup with icon and text
    func showSuccessPopup() {
        // Make the success pop-up visible
        successPopup.isHidden = false
        
        // Show the dimming view with gray background
        dimmingView.isHidden = false
        dimmingView.backgroundColor = UIColor(white: 0.2, alpha: 0.7) // Gray with transparency
    }

    // Dismiss the popup and navigate to login screen
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        // Dismiss the popup
        successPopup.isHidden = true
        
        // Hide the dimming view
        dimmingView.isHidden = true
        
        // Navigate to login screen
        performSegue(withIdentifier: "goToLogin", sender: self)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Apply corner radius only on the top corners of the success popup's topview
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
