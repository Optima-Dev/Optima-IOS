import UIKit

class EnterCodeViewController: UIViewController {

    @IBOutlet weak var codeTextField1: UITextField!
    @IBOutlet weak var codeTextField2: UITextField!
    @IBOutlet weak var codeTextField3: UITextField!
    @IBOutlet weak var codeTextField4: UITextField!
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var sendAgainButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setBackgroundImage()
        setupTextFields()
        setupButtons()

        // Add gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

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
        // Configure each text field for numeric input
        configureCodeTextField(codeTextField1)
        configureCodeTextField(codeTextField2)
        configureCodeTextField(codeTextField3)
        configureCodeTextField(codeTextField4)
    }

    func configureCodeTextField(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        textField.layer.borderWidth = 2.0
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)

        // Set the size of each text field
        textField.frame.size = CGSize(width: 85, height: 82) // Set custom width and height

        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.keyboardType = .numberPad // Only numbers allowed
        
        textField.delegate = self
    }

    func setupButtons() {
        verifyButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 20.0
        
        sendAgainButton.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        sendAgainButton.layer.borderWidth = 2.0
        sendAgainButton.layer.cornerRadius = 20.0
        sendAgainButton.backgroundColor = .white
        sendAgainButton.setTitleColor(UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1), for: .normal)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Action methods for buttons
    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        // Verify the code entered in the text fields
        let enteredCode = "\(codeTextField1.text ?? "")\(codeTextField2.text ?? "")\(codeTextField3.text ?? "")\(codeTextField4.text ?? "")"
        
        // Here you can perform verification of the entered code, e.g., network call
        print("Entered code: \(enteredCode)")
        
        // If valid code, proceed to next step
        if enteredCode.count == 4 {
            // Navigate to the next screen
            performSegue(withIdentifier: "goToResetPassword", sender: self)
        } else {
            // Handle invalid code input
            print("Invalid code")
        }
    }

    @IBAction func sendAgainButtonTapped(_ sender: UIButton) {
        // Resend the code, for example through a network call
        print("Resend code")
    }
}

extension EnterCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow numbers and limit each text field to one character
        if let currentText = textField.text, currentText.count == 1, !string.isEmpty {
            return false
        }

        // Proceed if the input is numeric or empty (backspace)
        if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil || string == "" {
            return true
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Move focus to the next text field
        if textField == codeTextField1 {
            codeTextField2.becomeFirstResponder()
        } else if textField == codeTextField2 {
            codeTextField3.becomeFirstResponder()
        } else if textField == codeTextField3 {
            codeTextField4.becomeFirstResponder()
        } else if textField == codeTextField4 {
            textField.resignFirstResponder() // Dismiss keyboard
        }
    }
}
