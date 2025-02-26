import UIKit

class EnterCodeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var codeTextField1: UITextField!
    @IBOutlet weak var codeTextField2: UITextField!
    @IBOutlet weak var codeTextField3: UITextField!
    @IBOutlet weak var codeTextField4: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var sendAgainButton: UIButton!
    
    // MARK: - Properties
    var userEmail: String! // Stores the user's email for verification purposes.
    private var codeTextFields: [UITextField] = [] // Array to hold all code text fields.
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received email: \(userEmail ?? "No email")") // Log the received email.
        setupUI() // Set up the user interface.
        setupCodeTextFields() // Configure the code text fields.
        setupGestureRecognizer() // Add gesture recognizer to dismiss the keyboard.
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setBackgroundImage() // Set the background image.
        setupButtons() // Configure the buttons.
    }
    
    private func setupCodeTextFields() {
        // Add all code text fields to the array.
        codeTextFields = [codeTextField1, codeTextField2, codeTextField3, codeTextField4]
        
        // Configure each text field.
        codeTextFields.forEach {
            $0.delegate = self // Set the delegate to self.
            configureCodeTextField($0) // Apply styling and configuration.
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged) // Add target for text change.
        }
        
        // Make the first text field the first responder.
        codeTextField1.becomeFirstResponder()
    }
    
    private func configureCodeTextField(_ textField: UITextField) {
        // Apply styling to the text field.
        textField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        textField.layer.borderWidth = 2.0
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.keyboardType = .numberPad
        textField.tintColor = .clear // Hide the cursor.
    }
    
    private func setupButtons() {
        // Configure the verify button.
        verifyButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 20.0
        verifyButton.isEnabled = false // Disable the button initially.
        
        // Configure the send again button.
        sendAgainButton.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        sendAgainButton.layer.borderWidth = 2.0
        sendAgainButton.layer.cornerRadius = 20.0
        sendAgainButton.backgroundColor = .white
        sendAgainButton.setTitleColor(UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1), for: .normal)
        
    }
    
    private func setBackgroundImage() {
        // Add a background image to the view.
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
        // Add a tap gesture recognizer to dismiss the keyboard.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        // Verify the entered code.
        guard let code = getEnteredCode(), code.count == 4 else {
            showInvalidCodeAlert() // Show an alert if the code is invalid.
            return
        }
        
        verifyCode(code) // Proceed with verification.
    }
    
    @IBAction func sendAgainButtonTapped(_ sender: UIButton) {
        // Resend the verification code.
        resendCode()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Handle text changes in the text fields.
        guard let text = textField.text else { return }
        
        if text.count == 1 {
            moveToNextTextField(after: textField) // Move to the next text field.
        }
        
        verifyButton.isEnabled = getEnteredCode()?.count == 4 // Enable the verify button if the code is complete.
    }
    
    @objc private func dismissKeyboard() {
        // Dismiss the keyboard.
        view.endEditing(true)
    }
    
    // MARK: - Code Handling
    private func getEnteredCode() -> String? {
        // Get the entered code by joining the text from all text fields.
        let code = codeTextFields.compactMap { $0.text }.joined()
        return code.count == 4 ? code : nil // Return the code only if it's complete.
    }
    
    private func moveToNextTextField(after currentTextField: UITextField) {
        // Move to the next text field or dismiss the keyboard if it's the last field.
        guard let index = codeTextFields.firstIndex(of: currentTextField),
              index < codeTextFields.count - 1 else {
            currentTextField.resignFirstResponder()
            return
        }
        
        codeTextFields[index + 1].becomeFirstResponder()
    }
    
    // MARK: - Networking Preparation
    private func verifyCode(_ code: String) {
        // Simulate code verification.
        print("Verifying code: \(code)")
        performSegue(withIdentifier: "goToResetPassword", sender: nil) // Navigate to the next screen.
    }
    
    private func resendCode() {
        // Simulate resending the code.
        print("Resending code to: \(userEmail ?? "")")
    }
    
    // MARK: - Error Handling
    private func showInvalidCodeAlert() {
        // Show an alert for invalid code.
        let alert = UIAlertController(
            title: "Invalid Code",
            message: "Please enter a valid 4-digit code",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EnterCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Handle pasted code or restrict input to digits only.
        if string.count > 1 {
            handlePastedCode(string)
            return false
        }
        
        let allowedCharacters = CharacterSet.decimalDigits
        return string.isEmpty || string.rangeOfCharacter(from: allowedCharacters) != nil
    }
    
    private func handlePastedCode(_ code: String) {
        // Handle pasted code by splitting it into individual digits.
        let digits = Array(code.prefix(4))
        for (index, digit) in digits.enumerated() where index < codeTextFields.count {
            codeTextFields[index].text = String(digit)
        }
        verifyButton.isEnabled = digits.count == 4 // Enable the verify button if the pasted code is complete.
    }
}
