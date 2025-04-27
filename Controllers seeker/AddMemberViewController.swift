// AddMemberViewController.swift
import UIKit

class AddMemberViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupKeyboardDismiss()
        setupTextFields()
    }
    
    // MARK: - Setup Methods
    private func setupBackground() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFields() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func sendRequestTapped(_ sender: UIButton) {
        guard let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespaces),
              let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespaces),
              let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            showAlert(message: "Please fill all required fields")
            return
        }
        
        FriendService.shared.sendFriendRequest(
            customFirstName: firstName,
            customLastName: lastName,
            helperEmail: email
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self?.showAlert(message: message) {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default) { _ in
                completion?()
            }
        )
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddMemberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
