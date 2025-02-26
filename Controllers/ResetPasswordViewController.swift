import UIKit

class ResetPasswordViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    
    // MARK: - Properties
    private let mainColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
    private let originalPlaceholder = "example@gmail.com"
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setBackgroundImage()
        setupEmailTextField()
        setupSendCodeButton()
    }
    
    private func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupEmailTextField() {
        emailTextField.layer.borderColor = mainColor.cgColor
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.cornerRadius = 20
        emailTextField.backgroundColor = .white
        
        let iconView = UIImageView(image: UIImage(named: "mail"))
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 12, y: 0, width: 24, height: 24)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        containerView.addSubview(iconView)
        
        emailTextField.leftView = containerView
        emailTextField.leftViewMode = .always
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: originalPlaceholder,
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }
    private func setupSendCodeButton() {
        sendCodeButton.layer.cornerRadius = 20
        sendCodeButton.backgroundColor = mainColor
        sendCodeButton.setTitleColor(.white, for: .normal)
        
        // Set font size to 28 and weight to semi-bold
        sendCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
    }
    // MARK: - Actions
    @IBAction func sendCodeButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        
        let validation = validateEmail(email)
        if validation.isValid {
            resetFieldAppearance()
            handleSendCode(email: email)
        } else {
            showError(message: validation.error ?? "Invalid email")
        }
    }
    
    // MARK: - Validation
    private func validateEmail(_ email: String) -> (isValid: Bool, error: String?) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        
        if email.isEmpty {
            return (false, "Email is required")
        }
        return isValid ? (true, nil) : (false, "Invalid email format")
    }
    
    private func showError(message: String) {
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: message,
            attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        emailTextField.layer.borderColor = UIColor.red.cgColor
    }
    
    private func resetFieldAppearance() {
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: originalPlaceholder,
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        emailTextField.layer.borderColor = mainColor.cgColor
    }
    
    // MARK: - Navigation
    private func handleSendCode(email: String) {
        // التحقق النهائي قبل الانتقال
        guard validateEmail(email).isValid else {
            showError(message: "Invalid email")
            return
        }
        
        print("✅ Valid email: \(email)")
        performSegue(withIdentifier: "goToEnterCode", sender: email)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEnterCode",
           let destinationVC = segue.destination as? EnterCodeViewController,
           let email = sender as? String {
            destinationVC.userEmail = email
        }
    }
}

// MARK: - UITextFieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resetFieldAppearance()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCodeButtonTapped(sendCodeButton)
        return true
    }
}
