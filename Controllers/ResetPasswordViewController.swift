import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()
        setupEmailTextField()  // Call the method to configure the email text field
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
    
    // Configure the email text field to match login/signup style
    func setupEmailTextField() {
        // Set border and styling for email text field
        emailTextField.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1).cgColor
        emailTextField.layer.borderWidth = 2.0
        emailTextField.layer.cornerRadius = 20.0
        emailTextField.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        
        // Set placeholder styling
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "example@gmail.com",
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)  // Adjusted font size
            ]
        )
        
        // Create email icon
        let emailIcon = UIImageView(image: UIImage(named: "mail"))
        emailIcon.contentMode = .scaleAspectFit
        emailIcon.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        iconContainer.addSubview(emailIcon)
        
        // Set the left view of the text field
        emailTextField.leftView = iconContainer
        emailTextField.leftViewMode = .always
        
        // Optional: Set delegate if needed for validation and keyboard control
        emailTextField.delegate = self
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    // Optionally, you can add any delegate methods for validation or keyboard control here
}
