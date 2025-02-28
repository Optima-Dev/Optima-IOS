import UIKit

class EnterCodeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var codeTextField1: UITextField!
    @IBOutlet weak var codeTextField2: UITextField!
    @IBOutlet weak var codeTextField3: UITextField!
    @IBOutlet weak var codeTextField4: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var sendAgainButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var userEmail: String!
    private var codeTextFields: [UITextField] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received email: \(userEmail ?? "No email")")
        setupUI()
        setupCodeTextFields()
        setupGestureRecognizer()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setBackgroundImage()
        setupButtons()
        errorLabel.isHidden = true
        activityIndicator.isHidden = true
    }
    
    private func setupCodeTextFields() {
        codeTextFields = [codeTextField1, codeTextField2, codeTextField3, codeTextField4]
        
        codeTextFields.forEach {
            $0.delegate = self
            configureCodeTextField($0)
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        codeTextField1.becomeFirstResponder()
    }
    
    private func configureCodeTextField(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        textField.layer.borderWidth = 2.0
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.keyboardType = .numberPad
        textField.tintColor = .clear
    }
    
    private func setupButtons() {
        verifyButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 20.0
        verifyButton.isEnabled = false
        
        sendAgainButton.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        sendAgainButton.layer.borderWidth = 2.0
        sendAgainButton.layer.cornerRadius = 20.0
        sendAgainButton.backgroundColor = .white
        sendAgainButton.setTitleColor(UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1), for: .normal)
    }
    
    private func setBackgroundImage() {
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(backgroundImage, at: 0)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        guard let code = getEnteredCode(), code.count == 4 else {
            showInvalidCodeAlert()
            return
        }
        
        verifyCode(code)
    }
    
    @IBAction func sendAgainButtonTapped(_ sender: UIButton) {
        resendCode()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count == 1 {
            moveToNextTextField(after: textField)
        }
        
        verifyButton.isEnabled = getEnteredCode()?.count == 4
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Code Handling
    private func getEnteredCode() -> String? {
        let code = codeTextFields.compactMap { $0.text }.joined()
        return code.count == 4 ? code : nil
    }
    
    private func moveToNextTextField(after currentTextField: UITextField) {
        guard let index = codeTextFields.firstIndex(of: currentTextField),
              index < codeTextFields.count - 1 else {
            currentTextField.resignFirstResponder()
            return
        }
        
        codeTextFields[index + 1].becomeFirstResponder()
    }
    
    private func verifyCode(_ code: String) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        verifyButton.isEnabled = false
        
        ResetPasswordService.shared.verifyCode(email: userEmail, code: code) { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.verifyButton.isEnabled = true
                
                switch result {
                case .success(let response):
                    if response.message == "Code verified" {
                        self.performSegue(withIdentifier: "goToResetPassword", sender: self.userEmail)
                    } else {
                        self.showError(message: response.message ?? "Unknown error")
                    }
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func resendCode() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        sendAgainButton.isEnabled = false
        
        ResetPasswordService.shared.sendCode(to: userEmail) { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.sendAgainButton.isEnabled = true
                
                switch result {
                case .success(let response):
                    if response.message == "Code sent successfully" {
                        self.showError(message: "Code sent successfully")
                    } else {
                        self.showError(message: response.message ?? "Unknown error")
                    }
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func showInvalidCodeAlert() {
        let alert = UIAlertController(
            title: "Invalid Code",
            message: "Please enter a valid 4-digit code",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResetPassword",
           let destinationVC = segue.destination as? ConfirmPasswordViewController {
            destinationVC.userEmail = self.userEmail
            print("✅ Email passed to ConfirmPasswordViewController: \(self.userEmail ?? "No email")") // Debugging
        }
    }
}

// MARK: - UITextFieldDelegate
extension EnterCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1 {
            handlePastedCode(string)
            return false
        }
        
        let allowedCharacters = CharacterSet.decimalDigits
        return string.isEmpty || string.rangeOfCharacter(from: allowedCharacters) != nil
    }
    
    private func handlePastedCode(_ code: String) {
        let digits = Array(code.prefix(4))
        for (index, digit) in digits.enumerated() where index < codeTextFields.count {
            codeTextFields[index].text = String(digit)
        }
        verifyButton.isEnabled = digits.count == 4
    }
}
