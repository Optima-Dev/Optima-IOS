import UIKit
import AVFoundation

class PrivacyTermsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var warningPopupView: UIView! // The warning popup itself

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the scroll view content size
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)
        
        // Hide the warning popup initially
        warningPopupView.isHidden = true
        
        // Check if permissions were previously granted
        if arePermissionsGranted() {
            // Permissions are already granted, navigate to login
            self.navigateToLogin()
        }
    }

    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        // Show permissions popup when "I Agree" is clicked
        showPermissionsPopup()
    }

    // Display system permission request popup
    func showPermissionsPopup() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Camera and Microphone",
                message: "Allow Optima to access your camera and microphone.",
                preferredStyle: .alert
            )

            let allowAction = UIAlertAction(title: "Allow", style: .default) { _ in
                self.requestPermissions()
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alert.addAction(cancelAction)
            alert.addAction(allowAction)

            self.present(alert, animated: true, completion: nil)
        }
    }

    // Request camera and microphone permissions
    func requestPermissions() {
        // Request camera permission
        AVCaptureDevice.requestAccess(for: .video) { cameraGranted in
            DispatchQueue.main.async {
                if cameraGranted {
                    // Request microphone permission after camera
                    self.requestMicrophonePermission()
                } else {
                    // Camera permission denied
                    print("Camera permission denied.")
                    self.showWarningPopup()
                }
            }
        }
    }

    // Request microphone permission using AVAudioSession
    func requestMicrophonePermission() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { microphoneGranted in
            DispatchQueue.main.async {
                if microphoneGranted {
                    // Store granted permissions and navigate to login
                    self.storePermissionsGranted()
                    self.navigateToLogin()
                } else {
                    // Microphone permission denied
                    print("Microphone permission denied.")
                    self.showWarningPopup()
                }
            }
        }
    }

    // Navigate to login screen
    func navigateToLogin() {
        DispatchQueue.main.async {
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            } else {
                print("Error: LoginViewController not found in storyboard.")
            }
        }
    }

    // Store permission status in UserDefaults
    func storePermissionsGranted() {
        UserDefaults.standard.set(true, forKey: "permissionsGranted")
    }

    // Check if permissions were granted previously
    func arePermissionsGranted() -> Bool {
        return UserDefaults.standard.bool(forKey: "permissionsGranted")
    }

    // Show the warning popup when permissions are denied
    func showWarningPopup() {
        DispatchQueue.main.async {
            self.warningPopupView.isHidden = false
        }
    }
}
